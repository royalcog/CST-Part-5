// Queen's DEFEND: her shield from the Chapter 2 battle. made by scr_queen_shield_build when she picks DEFEND.
//  build:    it builds up from the bottom in sections, each one settling onto the one below, until it's the whole shield
//  up:       blocks everything aimed at Queen. it darkens as it loses HP (spr_queen_shield frames 0 -> 1 -> 3)
//  down:     taken back down if DEFEND's undone before the round plays out (sections drop away, nothing breaks)
//  break:    out of HP, or the round's over: it cracks, then shatters into its shards (spr_queen_shield_break)
// x/y = its bottom-left (before bobbing), floating in front of Queen. it's mirrored for this fight (flip)
image_speed = 0;

// --- tuning ---
scale         = 1;      // the shield's 140px tall at 1x (Queen's 126 at her 2x)
flip          = true;   // turned around for this fight
front_gap     = 14;     // px between the front of Queen and the shield
float_h       = 12;     // px it floats off the ground
bob_amp       = 3;      // px it bobs up and down
bob_speed     = 0.06;
max_hp        = 400;    // Chapter 2's first shield
sections      = 10;     // how many pieces stack up into it
section_every = 3;      // frames between each piece
section_drop  = 10;     // px each piece drops in from
crack_frames  = 8;      // frames it shows cracked before it shatters
shard_gravity = 0.35;
build_sound   = snd_power;
hit_sound     = snd_damagetaken;
break_sound   = snd_glassbreak;

side          = 1;      // 1: on Queen's right, -1: on her left (set it and the shield swings round; cutscenes use this)
side_lerp     = 0.2;
// it starts on the side she's facing (her battle sprites face right; mirrored = facing left)
if (instance_exists(obj_queen) && obj_queen.image_xscale < 0) side = -1;

// --- state ---
hp      = max_hp;
state   = "build";
t       = 0;
flash   = 0;
shards  = [];
bob     = 0;

side_k  = side;         // where it is between her left (-1) and right (1) right now

follow_queen = function()
{
    if (!instance_exists(obj_queen)) return;
    // beside Queen (her sprite's right edge, or left with side = -1) + a gap. her origin's at her feet
    var _q  = obj_queen;
    var _e1 = _q.x + (0 - sprite_get_xoffset(_q.sprite_index)) * _q.image_xscale;
    var _e2 = _q.x + (sprite_get_width(_q.sprite_index) - sprite_get_xoffset(_q.sprite_index)) * _q.image_xscale;
    var _right_x = max(_e1, _e2) + front_gap;
    var _left_x  = min(_e1, _e2) - front_gap - sprite_get_width(spr_queen_shield) * scale;
    x = lerp(_left_x, _right_x, (side_k + 1) / 2);
    flip = side_k > 0;                       // its curved side faces out, whichever side it's on
    y = _q.y - float_h;
    depth = _q.depth - 1;                    // in front of her
}

/// draws rows _sy to _sy + _sh of the shield (frame _img), at _top + its own row + _dy. mirrored if flip is on
draw_band = function(_img, _sy, _sh, _top, _dy, _a)
{
    var _w = sprite_get_width(spr_queen_shield);
    var _yy = _top + _sy * scale + _dy;
    if (flip) draw_sprite_part_ext(spr_queen_shield, _img, 0, _sy, _w, _sh, x + _w * scale, _yy, -scale, scale, c_white, _a);
    else      draw_sprite_part_ext(spr_queen_shield, _img, 0, _sy, _w, _sh, x, _yy, scale, scale, c_white, _a);
}

/// draws a frame of _spr at (_lx, _ly) in the shield's own space (0 = its left edge), mirrored if flip is on
draw_part = function(_spr, _img, _lx, _ly, _a)
{
    var _w = sprite_get_width(spr_queen_shield) * scale;
    if (flip) draw_sprite_ext(_spr, _img, x + _w - _lx, _ly, -scale, scale, 0, c_white, _a);
    else      draw_sprite_ext(_spr, _img, x + _lx, _ly, scale, scale, 0, c_white, _a);
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