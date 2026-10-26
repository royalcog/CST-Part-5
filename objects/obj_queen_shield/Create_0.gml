// Queen's DEFEND: her shield from the Chapter 2 battle. made by scr_queen_shield_build when she picks DEFEND.
//  build:    its sections stack up from the bottom (spr_queen_shield_pieces), then it's the whole shield
//  up:       blocks everything aimed at Queen. it darkens as it loses HP (spr_queen_shield frames 0 -> 1 -> 3)
//  down:     taken back down if DEFEND's undone before the round plays out (sections drop away, nothing breaks)
//  break:    out of HP, or the round's over: it cracks, then shatters into its shards (spr_queen_shield_break)
// x/y = its bottom-left, in front of Queen
image_speed = 0;

// --- tuning ---
scale         = 1;      // the shield's 140px tall at 1x (Queen's 126 at her 2x)
offset_x      = 22;     // px in front of Queen's feet
max_hp        = 400;    // Chapter 2's first shield
sections      = 10;     // how many pieces stack up into it
section_every = 3;      // frames between each piece
section_drop  = 10;     // px each piece drops in from
crack_frames  = 8;      // frames it shows cracked before it shatters
shard_gravity = 0.35;
build_sound   = snd_power;
hit_sound     = snd_damagetaken;
break_sound   = snd_glassbreak;

// --- state ---
hp      = max_hp;
state   = "build";
t       = 0;
flash   = 0;
shards  = [];

follow_queen = function()
{
    if (!instance_exists(obj_queen)) return;
    x = obj_queen.x + offset_x;
    y = obj_queen.y;                         // her origin's at her feet
    depth = obj_queen.depth - 1;             // in front of her
}
follow_queen();

/// the shield's frame for how much HP it has left
hp_frame = function()
{
    var _k = hp / max_hp;
    return (_k > 0.66) ? 0 : ((_k > 0.33) ? 1 : 3);
}

/// something hit Queen while it's up: it takes it instead
hit = function(_amount)
{
    if (state != "up") return;
    hp -= _amount;
    flash = 1;
    if (hit_sound != noone) audio_play_sound(hit_sound, 1, false, 0.7);
    if (hp <= 0) shatter();
}

/// cracks, then shatters
shatter = function()
{
    if (state == "crack" || state == "shatter") return;
    state = "crack";
    t = 0;
}