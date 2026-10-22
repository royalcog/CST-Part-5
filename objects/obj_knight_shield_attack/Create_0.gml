// --- tuning ---
start_delay    = 20;   // box open -> it shrinks
box_scale      = 0.4;  // small square box, like Undertale's green mode
glide_lerp     = 0.15; // soul drifting to the middle while the box shrinks

// Ralsei's spell
ralsei_cast_sprite = spr_ralsei_spell;
ralsei_idle_sprite = spr_ralsei_battle_idle;
cast_frame     = 4;    // frame of his spell where the magic goes off
cast_sound     = snd_spell_pacify;
shake_frames   = 30;   // the soul shaking before it turns green
shake_amount   = 2;
change_sound   = snd_sparklegem;
change_gain    = 1.5;
flash_frames   = 20;
flash_radius   = 40;
green_color    = make_color_rgb(0, 255, 64);
learn_delay    = 60;   // shield appears -> first sword

// swords
sword_scale    = 1.2;
spawn_dist     = 300;  // how far out they start
fade_in        = 10;
tip_off        = (sprite_get_bbox_right(spr_roaringknight_sword) + 1 - sprite_get_xoffset(spr_roaringknight_sword)) * sword_scale; // origin -> tip
sword_damage   = 45;
hit_color_top    = c_white;
hit_color_bottom = c_white;
block_sound    = snd_impact;
spark_frames   = 12;

// feints: fly in, then whip around to the other side right before they land
feint_at          = 100;  // distance from the soul where they turn
feint_spin_frames = 18;
feint_color       = make_color_rgb(255, 220, 0);

// waves. pattern: "random" (any side, never 3 in a row) or "spin" (goes around the soul in order)
waves = [
    { count: 6,  speed: 4,   gap: 42, feint: 0,    pattern: "random" },
    { count: 10, speed: 5,   gap: 24, feint: 0,    pattern: "spin"   },
    { count: 10, speed: 5,   gap: 30, feint: 0.45, pattern: "random" },
    { count: 14, speed: 6.5, gap: 18, feint: 0.25, pattern: "random" }
];
wave_gap  = 50;
end_delay = 50;

// --- state ---
state       = "intro";
timer       = start_delay;
soul        = instance_exists(obj_soul) ? instance_find(obj_soul, 0) : noone;
ralsei_cast = false;
shake_x     = 0;
shake_y     = 0;
flash_t     = 0;
flash_x     = 0;
flash_y     = 0;
swords      = [];
sparks      = [];
wi          = 0;
spawned     = 0;
last_side   = -1;
same_count  = 0;
spin_side   = 0;
spin_step   = 1;

/// one sword from _side (0 right, 1 up, 2 left, 3 down), heading for the soul. dist = how far its TIP is from the soul
spawn_sword = function(_side, _speed, _feint)
{
    array_push(swords, { ang: _side * 90, dist: spawn_dist, speed: _speed, feint: _feint,
                         spin_t: -1, from_ang: 0, t: 0 });
}

pick_side = function(_pattern)
{
    if (_pattern == "spin")
    {
        var _s = spin_side;
        spin_side = (spin_side + spin_step + 4) mod 4;
        return _s;
    }
    var _s = irandom(3);
    if (_s == last_side && same_count >= 2) _s = (_s + 1 + irandom(2)) mod 4;
    same_count = (_s == last_side) ? same_count + 1 : 1;
    last_side  = _s;
    return _s;
}

ralsei_up = function() { return instance_exists(obj_ralsei) && scr_party_is_up(obj_ralsei); }