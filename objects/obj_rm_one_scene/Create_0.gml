// rm_one, right after the Knight finale: the Knight's by the cauldron, Susie calls him out,
// he cuts the castle door down and goes in, Ralsei runs in after him (around the cauldron), Susie follows
depth = -3500;
global.cutscene_lock = true;

// --- tuning ---
// where everyone stands (feet). the cauldron covers about x 320-440, y 244-356
knight_feet_x = 580;  knight_feet_y = 330;
susie_x  = 230;  susie_y  = 320;
ralsei_x = 175;  ralsei_y = 340;

walk_in          = true;  // they walk up from below the screen (false = already standing there)
walk_in_speed    = 2.5;
ralsei_walk_wait = 10;    // he comes in a beat after her
susie_point_sprite = spr_susie_point_right;
knight_facing      = -2; // his sprites face right, so -2 = facing left at 2x
knight_attack_facing = 2; // spr_knight_attack is already drawn facing left, so it doesn't get flipped

// Susie's planted (back) foot, in each sprite's own pixels: bottom-centre of the foot
susie_point_foot = { x: 10.5, y: 59 }; // spr_susie_point_right
susie_shock_foot = { x: 19,   y: 43 }; // spr_susie_shocked (the back foot, not the kicked-out one)
susie_walk_foot  = { x: 10.5, y: 43 }; // spr_susie_walk_right

// the Knight: standing pose = last frame of spr_roark_ball_to_knight. feet in each sprite's own pixels
knight_stand_sprite = spr_roark_ball_to_knight;
knight_stand_feet   = { x: 41, y: 77 };
knight_attack_feet  = { x: 65, y: 95 };
knight_hit_frame    = 3;   // frame of spr_knight_attack where the cut lands
knight_swing_sound  = snd_heavyswing;
knight_after_swing  = 25;  // holds the end of the swing this long

// into the room: same as the finale (back into the ball, flies to the door, fades out)
door_x       = 380;
door_y       = 196;  // the base of the door
ball_target_y = 170; // where the ball heads (a little inside the doorway)
leave_frames = 80;

// running in. the path goes up the left side of the cauldron, then across above it
path_x       = 290;   // left of the cauldron (its left edge is ~320)
path_top_y   = 215;   // above the cauldron, in front of the door
run_extra_up = 12;    // keeps going this far past the base of the door before fading
ralsei_run_speed = 7;
ralsei_run_anim  = 2.2;
susie_follow_wait = 28;
susie_run_speed  = 4.5;
susie_run_anim   = 1.6;
run_fade_speed   = 0.1;

// once they're both through the door: fade into rm_two
exit_fade_step = 0.05; // per frame (about a third of a second each way)
exit_fade_hold = 15;   // frames held on black
on_done = function()
{
    var _fader = instance_create_depth(0, 0, -10004, obj_cutscenefade);
    _fader.fade_target   = 1;
    _fader.fade_step     = exit_fade_step;
    _fader.target_room   = rm_two;
    _fader.wait_duration = exit_fade_hold;
};

// --- state ---
action = "";  busy = false;  sub = "";  t = 0;
saved = {};
steps_i = 0;  wait_t = 0;  talking = false;
runners = [];
point_looping = false; // Susie's point anim loops while her line types out
point_saw_box = false;
ball = { on: false, x: 0, y: 0, sx: 0, sy: 0, tx: 0, ty: 0, t: 0, frame: 0, xs: 1, scale: 2, alpha: 1 };

door = instance_exists(obj_door_break) ? instance_find(obj_door_break, 0) : instance_create_depth(0, 0, 250, obj_door_break);

// ------------------------------------------------------------ helpers

play   = function(_n) { action = _n; busy = true; sub = "start"; t = 0; saved = {}; }
go     = function(_s) { sub = _s; t = 0; }
finish = function() { action = ""; busy = false; sub = ""; }

/// moves _o so its feet are on (_fx, _fy)
set_feet = function(_o, _fx, _fy)
{
    var _f = scr_get_feet(_o);
    _o.x += _fx - _f.x;
    _o.y += _fy - _f.y;
    if (variable_instance_exists(_o, "start_y")) _o.start_y = _o.y;
}

/// stands still on frame 0 of _spr
stand = function(_o, _spr)
{
    if (!instance_exists(_o)) return;
    _o.sprite_index = _spr;
    _o.image_index  = 0;
    _o.image_speed  = 0;
}

/// swaps to _spr facing _xs (2 = right, -2 = left) without the feet moving
pose_facing = function(_o, _spr, _xs)
{
    if (!instance_exists(_o)) return;
    var _f = scr_get_feet(_o);
    _o.sprite_index = _spr;
    _o.last_sprite  = _spr; // already placed, so scr_auto_keep_feet leaves it alone
    _o.image_xscale = _xs;
    _o.image_index  = 0;
    _o.image_speed  = 0;
    set_feet(_o, _f.x, _f.y);
}

/// swaps _o to _spr (facing _xs) so pixel _to_px of the new sprite lands exactly where pixel _from_px of the old one was
pose_on_foot = function(_o, _spr, _xs, _from_px, _to_px)
{
    if (!instance_exists(_o)) return;
    var _fx = _o.x + (_from_px.x - sprite_get_xoffset(_o.sprite_index)) * _o.image_xscale;
    var _fy = _o.y + (_from_px.y - sprite_get_yoffset(_o.sprite_index)) * _o.image_yscale;

    _o.sprite_index = _spr;
    _o.last_sprite  = _spr; // placed by hand, so scr_auto_keep_feet leaves it alone
    _o.image_xscale = _xs;
    _o.image_index  = 0;
    _o.image_speed  = 0;

    _o.x = _fx - (_to_px.x - sprite_get_xoffset(_spr)) * _xs;
    _o.y = _fy - (_to_px.y - sprite_get_yoffset(_spr)) * _o.image_yscale;
}

/// a runner: { obj, pts:[{x,y}], i, speed, anim, wait, l, r, up, down, fade }
/// walks it toward its next point, with the walk sprite for whichever way it's mostly going. true when it's done
step_runner = function(_r)
{
    var _o = _r.obj;
    if (!instance_exists(_o)) return true;
    if (_r.wait > 0) { _r.wait--; return false; }

    if (_r.i >= array_length(_r.pts))
    {
        if (!_r.fade) return true;
        _o.image_alpha = max(_o.image_alpha - run_fade_speed, 0);
        if (_o.image_alpha <= 0) { _o.visible = false; return true; }
        return false;
    }

    var _p  = _r.pts[_r.i];
    var _f  = scr_get_feet(_o);
    var _dx = _p.x - _f.x, _dy = _p.y - _f.y;
    var _d  = point_distance(0, 0, _dx, _dy);
    var _spr = (abs(_dx) > abs(_dy)) ? ((_dx < 0) ? _r.l : _r.r) : ((_dy < 0) ? _r.up : _r.down);
    if (_o.sprite_index != _spr)
    {
        // coming out of her shocked pose: her walking feet go where her planted foot was
        if (_o.sprite_index == spr_susie_shocked)
            pose_on_foot(_o, spr_susie_walk_right, _o.image_xscale, susie_shock_foot, susie_walk_foot);
        _o.sprite_index = _spr;
        _o.anim_loop = true;
    }
    _o.image_speed = _r.anim;

    if (_d <= _r.speed) { _o.x += _dx; _o.y += _dy; _r.i++; }
    else { _o.x += _dx / _d * _r.speed; _o.y += _dy / _d * _r.speed; }
    return false;
}

susie_runner = function(_pts, _speed, _anim, _wait, _fade)
{
    return { obj: obj_susie, pts: _pts, i: 0, speed: _speed, anim: _anim, wait: _wait, fade: _fade,
             l: spr_susie_walk_left_neutral, r: spr_susie_walk_right_neutral, up: spr_susie_walk_up, down: spr_susie_walk_down_neutral };
}
ralsei_runner = function(_pts, _speed, _anim, _wait, _fade)
{
    return { obj: obj_ralsei, pts: _pts, i: 0, speed: _speed, anim: _anim, wait: _wait, fade: _fade,
             l: spr_ralsei_walk_left_neutral, r: spr_ralsei_walk_right_neutral, up: spr_ralsei_walk_up, down: spr_ralsei_walk_down };
}

/// the way in, from wherever _o is: over to the left of the cauldron, up past it, across, into the door
door_path = function(_o)
{
    var _f = scr_get_feet(_o);
    return [
        { x: path_x, y: _f.y },
        { x: path_x, y: path_top_y },
        { x: door_x, y: path_top_y },
        { x: door_x, y: door_y - run_extra_up }
    ];
}

/// Knight: switch between standing and swinging (and which way he's flipped) without his feet moving
knight_swap = function(_spr, _from_feet, _to_feet, _xs)
{
    if (!instance_exists(obj_knight)) return;
    with (obj_knight)
    {
        var _fx = x + _from_feet.x * image_xscale;
        var _fy = y + _from_feet.y * image_yscale;
        image_xscale = _xs;
        var _ny = _fy - _to_feet.y * image_yscale;
        start_y += _ny - y; // he bobs around start_y
        x = _fx - _to_feet.x * image_xscale;
        y = _ny;
        sprite_index = _spr;
    }
}

// ------------------------------------------------------------ the scene
steps = [
    { act: "setup" },                 // everyone in place (walking in during the fade)
    { wait: 20 },
    { act: "susie_point" },
    { text: "rm1_susie_point" },      // "What do you think you're doing???"
    { wait: 12 },
    { act: "knight_slash" },          // cuts the door down
    { wait: 25 },
    { act: "knight_enter" },          // into the ball, through the door
    { wait: 15 },
    { text: "rm1_ralsei_no" },        // "N-No...", "NO!!!"
    { act: "run_in" }                 // Ralsei runs in, Susie right after
];

run_steps = function()
{
    if (busy) return true;
    if (talking) { if (instance_exists(obj_textbox)) return true; talking = false; }
    if (wait_t > 0) { wait_t--; return true; }
    if (steps_i >= array_length(steps)) return false;

    var _st = steps[steps_i];
    steps_i++;
    if (variable_struct_exists(_st, "act"))  play(_st.act);
    if (variable_struct_exists(_st, "text")) { create_textbox(_st.text); talking = true; }
    if (variable_struct_exists(_st, "wait")) wait_t = _st.wait;
    return true;
}