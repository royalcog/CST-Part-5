// the Titan reveal at the top of the tower (Ch4's obj_titan_enemy_actor, ported to 60fps).
// the Titan's already standing there with its wings wrapped shut, hidden under a black square:
//   blackout()  - the black square fades in (the Titan's drawn underneath from the crescent on)
//   crescent()  - snd_motor_ghost, the highlight on the edge of the closed wings fades in, then it holds
//   open()      - snd_ghostappear, the black + crescent fade off, then the wings open (snd_titan_wingshut) into its idle
// obj_tower_top_scene makes it (titan_reveal) and drives it. it sits behind the clouds and the floor.
// Ch4's frame counts are at 30fps: everything here is doubled (and per-frame speeds halved).

// --- tuning: where it stands. Ch4 puts its top-left corner 494px in from the right edge of the screen and
//     88px above the top, at 2x (so it hangs off the right side). measured from the camera when it's made ---
scale        = 2;
right_inset  = 450;           // px in from the right edge of the screen (its left edge). Ch4: 494 (on a 640-wide screen)
top_offset   = -88;           // px from the top of the screen (its top edge)
depth        = 25;            // in front of the cloud sea (50), behind the floor (Tiles_1, 0) and everyone on it

// --- tuning: timing (60fps) ---
blackout_fade   = 60;         // the black square fading in
blackout_hold   = 120;        // frames into the black-out that the crescent starts
crescent_fade   = 60;         // the crescent fading in
crescent_hold   = 120;        // frames into the crescent that it's done (then it holds until open())
open_fade       = 30;         // the black + crescent fading off
open_wings_at   = 90;         // frames into open() that the wings start opening
wing_speed      = 1 / 12;     // wing frames per frame (6 frames to open: 72 frames)
anim_speed      = 1 / 12;     // the body / wings' idle animation, frames per frame
wobble_accel    = 0.1;        // the closed wings' star circling: speeds up to...
wobble_max      = 1.5;        // ...this many degrees per frame
wobble_dist     = 4;          // px each closed-wing layer sits off centre
crescent_dx     = 210;        // where the crescent sits, from its top-left (Ch4's numbers)
crescent_dy     = 110;
motor_pitch     = 0.6;
afterimage_at   = 1.4;        // the wings' frame (counting down from 6) that the screen afterimage goes off
afterimage_anchor_from_right = 180;   // Ch4: 460 of 640 across
afterimage_anchor_y          = 200;
afterimage_grow = 0.005;      // scale per frame
afterimage_fade = 0.025;      // alpha per frame (from 0.5)

// --- tuning: the clouds in front of its bottom edge (so it looks like it's standing in them, not cut off).
//     no new clouds: the cloud sea's own puffs that are already sitting along its bottom edge get drawn again
//     in front of it, in exactly the same spots, so nothing pops in. measured from its top-left, room px ---
cloud_band_top    = 375;      // sea puffs lower than this go in front (the Titan's 420 tall at 2x: its bottom's at 420)
cloud_band_pad    = 40;       // px past its left/right edges

// what runs when each part's done (the scene sets these)
on_crescent_done = undefined;
on_open_done     = undefined;

// --- place it ---
var _cx = camera_get_view_x(view_camera[0]);
var _cy = camera_get_view_y(view_camera[0]);
var _vw = camera_get_view_width(view_camera[0]);
x = _cx + _vw - right_inset;   // its top-left corner (Ch4 draws everything from there)
y = _cy + top_offset;

// --- state ---
stage       = "hidden";       // hidden -> blackout -> crescent -> hold -> open -> idle
t           = 0;
drawstate   = "defense end";  // the wings start shut ("defense end"), then "undefense" (opening), then "idle"
wing_t      = 6;              // the wings' frame while opening (6 = shut, 0 = open)
siner       = 0;
rotation    = 0;
spd         = 0;
a_black     = 0;              // the black square
a_crescent  = 0;
show_titan  = false;          // Ch4: introcon > 0
open_done   = false;

after_surf  = -1;             // the screen afterimage
after_on    = false;
after_grab  = false;
after_scale = 1;
after_alpha = 0.5;

// --- the cloud sea's puffs along its bottom edge (picked once: they're the sea's own, so they bob in step with it) ---
cloud_sea   = noone;
cloud_puffs = [];
var _x0 = x - cloud_band_pad;
var _x1 = min(x + sprite_get_width(spr_titan_0_backwing) * scale, _cx + _vw) + cloud_band_pad;
var _ytop = y + cloud_band_top;
with (obj_plat_cloud)
{
    if (mode != "sea") continue;
    other.cloud_sea = id;
    for (var i = 0; i < array_length(puffs); i++)
    {
        var _p = puffs[i];
        if (_p.y >= _ytop && _p.x >= _x0 && _p.x <= _x1) array_push(other.cloud_puffs, _p);
    }
}

/// draws _spr frame _img with its top-left corner at (_x, _y) at our scale (the sprites' origins are centred:
/// Ch4's were top-left, so this puts them where Ch4's numbers expect)
draw_tl = function(_spr, _img, _x, _y, _a = 1)
{
    if (_a <= 0) return;
    draw_sprite_ext(_spr, _img, _x + sprite_get_xoffset(_spr) * scale, _y + sprite_get_yoffset(_spr) * scale, scale, scale, 0, c_white, _a);
}

/// the same, as a black silhouette (alpha _a): how it's hidden in the dark before the reveal
draw_tl_black = function(_spr, _img, _x, _y, _a)
{
    if (_a <= 0) return;
    gpu_set_fog(true, c_black, 0, 0);
    draw_tl(_spr, _img, _x, _y, _a);
    gpu_set_fog(false, c_white, 0, 0);
}

// ---------------------------------------------------------------- commands
blackout = function()
{
    stage = "blackout";
    t = 0;
}

crescent = function()
{
    stage = "crescent";
    t = 0;
    show_titan = true;
    a_black = 1;
    audio_play_sound(snd_motor_ghost, 1, false, 1, 0, motor_pitch);
}

open = function()
{
    stage = "open";
    t = 0;
    show_titan = true;
    audio_play_sound(snd_ghostappear, 1, false);
}

/// skips straight to the Titan standing there, wings open (for testing the battle)
skip_to_idle = function()
{
    stage = "idle";
    t = 0;
    show_titan = true;
    a_black = 0;
    a_crescent = 0;
    drawstate = "idle";
    open_done = true;
}