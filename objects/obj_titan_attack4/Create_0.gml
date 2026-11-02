// Titan attack 4: Deltarune Ch4's Titan hands (obj_titan_battle_hands_manager + obj_titan_battle_finger), ported.
// two hands either side of the box, bobbing and swaying. each cycle they pull back, shake, slam in at the box, then
// every finger fires 3 dark wibbly bullets. the SOUL's light purifies a finger's weak spot (near its tip): keep it
// there and the finger breaks (COURAGE comes out). all 4 broken on a hand: it overloads and blows up.
// ours: the box turns with the hands as they sway, and holds still while they slam.
// Deltarune's 30fps: frame counts doubled, per-frame speeds halved. the hands are drawn the way Deltarune does them:
// onto a surface, then in wobbling strips while they fade in and out

// ---------------------------------------------------------------- tuning
difficulty      = 1;       // Deltarune's 0-2: how quick each cycle is
attack_time     = 720;     // frames before the hands fade out
end_fade        = 40;      // frames they take to fade out
damage          = 110;     // fingers + hands (DR 90, scaled up like the Titan Spawn's)
bullet_damage   = 110;     // the wibbly bullets (DR 90)
turn_mult       = 24;      // degrees the box turns per unit of the hands' sway speed (0: the box doesn't turn)
base_speed      = 0.065;   // DR 0.13: the hands bobbing up and down
base_angle_speed = 0.025;  // DR 0.05: the hands swaying (and the box turning)
curl_speed      = 0.25;    // DR 0.5: finger frames a frame when they curl
light_up        = 0.0175;  // DR 0.035: a finger's light filling while its weak spot's in the SOUL's light...
light_down      = 0.0022;  // ...draining when it isn't (DR's middle phases)
weak_bonus      = 52;
wibbly_cooldown = 20;      // DR 10: frames between a finger's 3 bullets
hand_kill_r     = 60;      // a bullet this close to the other hand is gone
soul_hit_r      = 5;       // px: the SOUL's hitbox for this attack, a circle in its middle (Deltarune's is tiny)
break_run_sound = noone;   // Deltarune's sound 261 (the rising run when a finger breaks)
finger_sprite   = spr_titan_battle_finger;
weak_sprite     = spr_titan_battle_finger_weakspot;

// ---------------------------------------------------------------- state
t     = 0;
vw    = camera_get_view_width(view_camera[0]);
vh    = camera_get_view_height(view_camera[0]);
image_alpha = 0;
hands_surface = -1;
aura_radius = 0;
counter = irandom(999);
counter_speed = 0;
angle_counter = irandom(999);
angle_counter_speed = 0;
hand_distance = 280;
hand_direction = 0;
wave_counter = 0;
turn = instance_exists(obj_battlebox) ? obj_battlebox.box_angle : 0;
alarms = array_create(5, -1);
tweens = [];
bullets = [];
booms = [];
specks = [];
afters = [];
ending = false;
gone_t = 0;

// ---------------------------------------------------------------- helpers
/// Deltarune's scr_lerpvar: type 0 = linear, 1+ = steeper. _mode "in" / "out" / "inout"
ease = function(_k, _type, _mode)
{
    if (_type <= 0) return _k;
    var _p = _type + 1;
    if (_mode == "out")   return 1 - power(1 - _k, _p);
    if (_mode == "inout") return (_k < 0.5) ? power(2 * _k, _p) / 2 : 1 - power(2 - 2 * _k, _p) / 2;
    return power(_k, _p);
}
tween = function(_name, _from, _to, _dur, _type = 0, _mode = "in", _delay = 0)
{
    if (_delay <= 0)
        for (var i = array_length(tweens) - 1; i >= 0; i--) if (tweens[i].name == _name && tweens[i].delay <= 0) array_delete(tweens, i, 1);
    array_push(tweens, { name: _name, from: _from, to: _to, dur: max(1, _dur), type: _type, mode: _mode, delay: _delay, t: 0 });
}

/// does a piece (drawn with _mask at this pose) touch the SOUL's hitbox? (borrows this instance's own mask and
/// position for a moment, then puts its position back)
touches = function(_mask, _img, _x, _y, _xs, _ys, _ang)
{
    if (!instance_exists(obj_soul)) return false;
    var _ox = x, _oy = y;
    x = _x;
    y = _y;
    mask_index   = _mask;
    image_index  = _img;
    image_xscale = _xs;
    image_yscale = _ys;
    image_angle  = _ang;
    var _hit = collision_circle(obj_soul.x, obj_soul.y, soul_hit_r, id, true, false) != noone;
    x = _ox;
    y = _oy;
    return _hit;
}

/// a hand: 0 = Deltarune's hand_1 (yscale -2), 1 = hand_2. its fingers sit at (side, forward) from it
make_hand = function(_n)
{
    var _h = { n: _n, x: 0, y: 0, ang: 0, xs: 2, ys: (_n == 0) ? -2 : 2, broken: 0, ov_t: -1, out_dir: 0,
               bx: 0, by: 0, gone: false, fingers: [] };
    var _slots = (_n == 0) ? [[-52, 68], [-2, 72], [51, 68], [103, 53]] : [[-103, 53], [-51, 68], [2, 72], [52, 68]];
    var _wd    = (_n == 0) ? [0, 43, 0, 43] : [43, 0, 43, 0];
    var _short = (_n == 0) ? [true, false, true, false] : [false, true, false, true];
    for (var i = 0; i < 4; i++)
    {
        var _off = [0, 10, 14, 14, 15, 14, 14, 10];
        if (_short[i]) for (var k = 0; k < 8; k++) _off[k] *= 0.75;
        array_push(_h.fingers, { alive: true, slot: i, side: _slots[i][0], fwd: _slots[i][1], x: 0, y: 0, ang: 0,
                                 xs: 2, ys: (_n == 0) ? 2 : -2, img: 0, ispd: 0, curl_in: -1, light: 0,
                                 weak_dist: _wd[i], weak_off: _off, shots_left: 0, shot_in: -1 });
    }
    return _h;
}
hands = [ make_hand(0), make_hand(1) ];

/// where a finger's weak spot is
weak_pos = function(_f)
{
    var _d = _f.weak_dist - _f.weak_off[clamp(floor(_f.img), 0, 7)] * 2 + weak_bonus;
    return { x: _f.x + lengthdir_x(_d, _f.ang), y: _f.y + lengthdir_y(_d, _f.ang) };
}

/// the fingers curl one after another (each plays its frames once, then springs back open)
curl_fingers = function()
{
    for (var h = 0; h < 2; h++)
        for (var i = 0; i < 4; i++)
        {
            var _f = hands[h].fingers[i];
            if (_f.alive) _f.curl_in = 4 * (i + 1);
        }
}

// --- bullets ---
add_bullet = function(_x, _y, _dir, _sf, _st, _owner)
{
    array_push(bullets, { x: _x, y: _y, dir: _dir, spd: _sf, sf: _sf, st: _st, t: 0, f: 0, s: 0, owner: _owner, a: 1 });
}
/// a finger's bullet: out past its tip, any direction, slowly speeding up
finger_shot = function(_h, _f)
{
    var _l = 110 + irandom(20);
    add_bullet(_f.x + lengthdir_x(_l, _f.ang), _f.y + lengthdir_y(_l, _f.ang), irandom(360), 0, 0.75, _h.n);
}
/// a broken finger's stump: a bullet roughly the way the hand's pointing
stump_shot = function(_h, _f)
{
    var _x = _h.x + lengthdir_x(_f.fwd, _h.ang) + lengthdir_x(_f.side, _h.ang + 90);
    var _y = _h.y + lengthdir_y(_f.fwd, _h.ang) + lengthdir_y(_f.side, _h.ang + 90);
    add_bullet(_x, _y, _h.ang + irandom_range(-25, 25), 0.5, 1, _h.n);
}

// --- explosions (Deltarune's obj_battle_marker) ---
add_boom = function(_x, _y, _dir, _spd, _bb, _spd_time)
{
    array_push(booms, { spr: spr_finisher_explosion, x: _x, y: _y, f: 0, fspd: ((0.075 * _bb) + 0.4) / 2,
                        dir: _dir, spd: _spd, spd0: _spd, spd_time: _spd_time, t: 0,
                        s_from: 0.5, s_to: 0.25, s_time: max(1, 8 * ((0.25 * _bb) + 0.5)), xs: 1, ys: 1, ang: irandom(360) });
}
add_shock = function(_x, _y, _fspd, _xs, _ys)
{
    array_push(booms, { spr: spr_titan_shockwave_bullet_explosion, x: _x, y: _y, f: 0, fspd: _fspd,
                        dir: 0, spd: 0, spd0: 0, spd_time: 1, t: 0,
                        s_from: 1, s_to: 1, s_time: 1, xs: _xs, ys: _ys, ang: irandom(360) });
}

/// the SOUL's light burnt a finger out
break_finger = function(_h, _f)
{
    _f.alive = false;
    audio_play_sound(snd_explosion_firework, 1, false);
    _h.broken++;
    if (_h.broken == 4)
    {
        // overload: it slides back out, going white, then blows
        _h.ov_t = 0;
        _h.out_dir = hand_direction + _h.n * 180;
        _h.bx = _h.x;
        _h.by = _h.y;
    }
    for (var bb = -1; bb < 5; bb++)
    {
        var _bx = _f.x + lengthdir_x(20 * bb, _f.ang), _by = _f.y + lengthdir_y(20 * bb, _f.ang);
        if (bb > 0 && break_run_sound != noone)
            scr_call_after_frames(function() { audio_play_sound(break_run_sound, 1, false, 1, 0, 0.75); }, bb * 4);
        instance_create_depth(_bx + irandom_range(-5, 5), _by + irandom_range(-5, 5), depth, obj_darkshape_greenblob);
        repeat (2) add_boom(_bx + irandom_range(-15, 15), _by + irandom_range(-15, 15), irandom(360), 4, bb, 16);
    }
}

/// Deltarune's alarms 0-4: one cycle of the hands
fire_alarm = function(_a)
{
    switch (_a)
    {
        case 0:   // curl, slow to a stop
            curl_fingers();
            var _d0 = (difficulty < 2) ? 30 : 20;
            tween("counter_speed", counter_speed, 0, _d0);
            tween("angle_counter_speed", angle_counter_speed, 0, _d0);
            alarms[1] = (difficulty < 2) ? 20 : 10;
        break;
        case 1:   // pull back
            tween("hand_distance", 280, 400, (difficulty < 2) ? 40 : 30, 3, "out");
            alarms[2] = (difficulty < 2) ? 50 : 40;
        break;
        case 2:   // slam in
            audio_play_sound(snd_bigcut, 1, false);
            tween("hand_distance", 400, 170, (difficulty < 2) ? 40 : 30, 3, "out");
            alarms[3] = (difficulty == 0) ? 80 : ((difficulty == 1) ? 60 : 40);
        break;
        case 3:   // back out, every finger fires
            audio_play_sound(snd_ultraswing, 1, false, 1, 0, 0.75);
            for (var h = 0; h < 2; h++)
                for (var i = 0; i < 4; i++)
                {
                    var _f = hands[h].fingers[i];
                    if (_f.alive) { _f.shots_left = 3; _f.shot_in = 1; }
                }
            tween("hand_distance", 170, 280, (difficulty < 2) ? 80 : 60, 1, "out");
            alarms[4] = 40;
        break;
        case 4:   // curl, start swaying again (a new random way), the side-to-side wave
            curl_fingers();
            var _sp = (difficulty == 0) ? 60 : ((difficulty == 1) ? 20 : 10);
            tween("counter_speed", counter_speed, base_speed, _sp);
            tween("angle_counter_speed", angle_counter_speed, choose(base_angle_speed, -base_angle_speed), _sp);
            if (difficulty == 0)
            {
                tween("wave_counter", 0, pi / 2, 40);
                tween("wave_counter", pi / 2, pi * 1.5, 100, 0, "in", 40);
                tween("wave_counter", pi * 1.5, pi * 2, 40, 0, "in", 140);
                alarms[0] = 160;
            }
            else if (difficulty == 1)
            {
                tween("wave_counter", 0, pi / 2, 10);
                tween("wave_counter", pi / 2, pi * 1.5, 20, 0, "in", 20);
                tween("wave_counter", pi * 1.5, pi * 2, 30, 0, "in", 40);
                alarms[0] = 50;
            }
            else
            {
                tween("wave_counter", 0, pi / 2, 10);
                tween("wave_counter", pi / 2, pi * 1.5, 20, 0, "in", 10);
                tween("wave_counter", pi * 1.5, pi * 2, 30, 0, "in", 30);
                alarms[0] = 40;
            }
        break;
    }
}

// start: fade in, start bobbing and swaying, first cycle a second in
tween("image_alpha", 0, 1, 60);
tween("counter_speed", 0, base_speed, 60);
tween("angle_counter_speed", 0, choose(base_angle_speed, -base_angle_speed), 60);
alarms[0] = 60;