// --- tuning ---
beam_spacing   = 22;              // must stay under 2x beam_hit_radius so nothing slips between spades
beam_gap_slots = [ [3, 4], [7, 8] ]; // missing slots per arm (slot 0 = center) — arm 1's gap is inner, arm 2's is outer
beam_damage     = 36;
beam_hit_radius = 12;

// beam spin (deg/frame) over time — eases toward whichever key it's currently past
spin_keys = [
    { at: 0,    spin: 0.6  },
    { at: 300,  spin: 1.0  },
    { at: 540,  spin: -0.8 },   // first reversal
    { at: 780,  spin: -1.3 },
    { at: 1000, spin: 1.2  },   // second reversal
    { at: 1180, spin: 1.5  }
];
spin_ease     = 0.03;
beam_duration = 1320; // frames of storm (~22s)
windup_frames = 60;   // red telegraph line before the beam appears (soul spawns on it)
telegraph_color = c_red;
telegraph_width = 3;
reverse_sound = snd_impact; // -1 for none
reverse_shake = 3;

// box sway — tilts back and forth while the storm runs
sway_amount      = 10;   // max tilt in degrees either way
sway_period      = 240;  // frames for one full sway back and forth
sway_ramp_frames = 120;  // eases into the full sway at the start

// snipers: single spades that pop up, lock onto the soul, and fire
sniper_gap_start = 110;  // frames between snipers at the start...
sniper_gap_end   = 40;   // ...down to this by the end
sniper_aim       = 34;   // wind-up length (was 45) — shorter = shows up and locks on quicker
sniper_lock      = 10;   // dodge window after it stops tracking — unchanged
sniper_fade      = 5;    // fade-in frames (was 8)
sniper_turn      = 0.35; // how fast it swings to face the soul (was 0.25)
sniper_blink     = 20;   // blinks red for the last N frames of the wind-up
sniper_min_dist  = 80;   // never spawns closer than this to the soul
sniper_margin    = 20;   // stays this far inside the box walls
sniper_damage     = 36;
sniper_hit_radius = 12;
sniper_fire_sound = snd_smallswing; // -1 for none

end_delay   = 40;   // beam fades while slowing down and the sway settles, then the box closes
start_sound = snd_spear_appear; // -1 for none

// --- state ---
depth = obj_battlebox.depth - 1;
state = "windup";
timer = windup_frames;
storm_timer  = 0;
sniper_timer = sniper_gap_start;
beam_angle = choose(0, 45, 90, 135) + random_range(-15, 15);
cur_spin   = 0;
last_target_spin = spin_keys[0].spin;
beam = []; // { inst, arm, r }

var _c = scr_box_center();
cx = _c.x;
cy = _c.y;

with (obj_box_bullet_drawer) instance_destroy(); // clear any leftover
instance_create_depth(0, 0, obj_battlebox.depth - 1, obj_box_bullet_drawer);

spawn_beam = function()
{
    var _in = scr_get_box_interior();
    var _reach = point_distance(0, 0, (_in.x2 - _in.x1) / 2, (_in.y2 - _in.y1) / 2); // center to corner
    var _n = ceil(_reach / beam_spacing) + 1;

    for (var _arm = 0; _arm < 2; _arm++)
    {
        var _gaps = beam_gap_slots[_arm];
        for (var k = (_arm == 0 ? 0 : 1); k < _n; k++) // center slot only once
        {
            if (array_contains(_gaps, k)) continue;

            var _s = instance_create_depth(cx, cy, obj_battlebox.depth - 1, obj_spade_shot);
            _s.move_speed = 0;
            _s.max_speed  = 0;
            _s.damage     = beam_damage;
            _s.hit_radius = beam_hit_radius;
            _s.entered    = true;
            _s.life       = 100000;

            array_push(beam, { inst: _s, arm: _arm, r: k * beam_spacing });
        }
    }
    update_beam();
};

update_beam = function()
{
    for (var i = 0; i < array_length(beam); i++)
    {
        var _b = beam[i];
        if (!instance_exists(_b.inst)) continue;

        var _a = beam_angle + _b.arm * 180;
        _b.inst.x = cx + lengthdir_x(_b.r, _a);
        _b.inst.y = cy + lengthdir_y(_b.r, _a);
        _b.inst.move_dir    = _a; // points outward along its arm
        _b.inst.image_angle = _a;
    }
};

spawn_sniper = function()
{
    var _in = scr_get_box_interior();
    var _pos = { x: cx, y: cy };

    for (var _try = 0; _try < 12; _try++)
    {
        // pick a spot in the box's own frame, then place it in the (possibly tilted) world
        _pos = scr_box_local_to_world(
            random_range(_in.x1 + sniper_margin, _in.x2 - sniper_margin),
            random_range(_in.y1 + sniper_margin, _in.y2 - sniper_margin));
        if (!instance_exists(obj_soul) || point_distance(_pos.x, _pos.y, obj_soul.x, obj_soul.y) >= sniper_min_dist) break;
    }

    var _s = instance_create_depth(_pos.x, _pos.y, obj_battlebox.depth - 1, obj_spade_shot);
    _s.image_angle  = random(360); // swings into its aim during the wind-up
    _s.aim_frames   = sniper_aim;
    _s.lock_frames  = sniper_lock;
    _s.aim_turn     = sniper_turn;
    _s.blink_frames = sniper_blink;
    _s.fade_frames  = sniper_fade;
    _s.move_speed   = 1;     // same shot speed as before
    _s.accel        = 0.25;
    _s.max_speed    = 7;
    _s.damage       = sniper_damage;
    _s.hit_radius   = sniper_hit_radius;
    _s.fire_sound   = sniper_fire_sound;
    _s.entered      = true;
};

apply_sway = function(_amp_mult)
{
    var _ramp = clamp(storm_timer / sway_ramp_frames, 0, 1);
    obj_battlebox.box_angle = sway_amount * _ramp * _amp_mult * sin(storm_timer * 2 * pi / sway_period);
};