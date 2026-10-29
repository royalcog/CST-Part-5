// Titan Spawn attack 1: Deltarune Ch4's darkshape attack (obj_darkshape_manager's pattern_default / pattern_default_intro).
// Deltarune is 30fps and we're 60, so its per-frame speeds/rates are halved and frame counts doubled.

// --- tuning ---
pattern          = "intro";    // the real turn 1: a copy every 48 frames (DR 24) at 0.85 size, no red shapes
attack_duration  = 720;        // Deltarune's 12-second turn
aura_radius      = 48;         // the soul's light: Deltarune's light_radius (Brighten makes it 63)
damage           = 110;        // Titan Spawn AT 18 -> 90 in Ch4, scaled up for your bigger HP (Susie 230 -> 290, Ralsei 180 -> 210)
glow_strength    = 1;          // how bright the soul's light is (not how big)
spawn_ring_min   = 75;         // px outside the box edge they spawn (DR: 150-200 from the centre of its ~150px box)
spawn_ring_extra = 50;
ominous_max_gain = 0.6;
red_every        = 0;          // every Nth spawn is a red shape instead (0 = none). attack 2 sets it

spawn_gap   = (pattern == "intro") ? 48 : 24;
spawn_scale = (pattern == "intro") ? 0.85 : 1;

// --- state ---
t          = 0;
dark_count = 0;      // how many have been purified
in_light   = false;  // set by any copy that's in the light this frame
particles  = [];
flare  = 0;    // the light swells/brightens while something's being purified
burst  = 0;    // a pulse ring when one's purified
glow_x = instance_exists(obj_soul) ? obj_soul.x : 0;   // the light trails the SOUL a touch
glow_y = instance_exists(obj_soul) ? obj_soul.y : 0;
spawn_counter = 0;

// sounds: snd_spawn_attack loops all attack; the organ loop starts silent at 0.25 pitch and swells while copies are being purified
spawn_loop     = audio_play_sound(snd_spawn_attack, 1, true);
ominous_volume = 0;
ominous_loop   = audio_play_sound(snd_organ_enemy_loop_temp, 1, true, 0, 0, 0.25);

/// where on the ring the next spawn goes: { dir, dist }. attack 4 overrides it
spawn_pos = function(_half)
{
    return { dir: irandom(360), dist: _half + spawn_ring_min + irandom(spawn_ring_extra) };
}

/// a copy (or a red shape) at a random angle on a ring outside the box (like Deltarune)
spawn_shape = function()
{
    var _c    = scr_box_center();
    var _in   = scr_get_box_interior();
    var _half = max(_in.x2 - _in.x1, _in.y2 - _in.y1) / 2;
    var _sp   = spawn_pos(_half);
    var _dir  = _sp.dir;
    var _dist = _sp.dist;
    var _x    = _c.x + lengthdir_x(_dist, _dir), _y = _c.y + lengthdir_y(_dist, _dir);

    // Deltarune: every 5th one's a red shape, fired straight at the SOUL
    if (red_every > 0 && (spawn_counter mod red_every) == red_every - 1)
    {
        with (instance_create_depth(_x, _y, depth, obj_redshape)) { ctrl = other.id; damage = other.damage; }
    }
    else with (instance_create_depth(_x, _y, depth, obj_darkshape))
    {
        ctrl        = other.id;
        scalefactor = other.spawn_scale;
        damage      = other.damage;
        dir         = (y >= _c.y) ? 250 - irandom(10) : 110 + irandom(10);   // DR's starting direction, then it curves in
    }
    spawn_counter++;
}