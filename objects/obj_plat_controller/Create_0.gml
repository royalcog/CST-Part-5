// the tower climb (rm_tower). makes Susie and Ralsei, runs swapping (C) and the follower, moves the camera,
// and opens self_5 once the white flash has faded. you play once self_5 closes.
global.plat_lock     = true;   // no control until self_5 is done
global.cutscene_lock = true;   // Z doesn't open self_ dialogue up here (the climb opens its own)
global.textbox_top   = false;

// --- tuning ---
plat_show_solids = true;   // the grey placeholder blocks. false once your tiles are over them
start_gap     = 64;        // px Ralsei starts behind Susie
follow_delay  = 18;        // how far back on your trail the follower walks (in steps of your trail)
catch_up      = 30;        // if they fall this many steps further behind, they walk double speed
hist_max      = 600;
swap_key      = ord("C");
swap_cool_max = 15;        // frames between swaps
swap_sound    = snd_select;
intro_wait    = 30;        // frames after the white's gone before self_5
cam_lead_y    = 0.62;      // the controlled one's feet sit this far down the screen
cam_lerp      = 0.18;      // how quickly the camera catches up (1 = locked on)

// --- state ---
state     = "fadein";
t         = 0;
party     = [];
leader_i  = 0;
hist      = [];    // the trail the follower walks: { x, y, g (on the ground), f (facing) }
fi        = 0;     // where on it the follower is
swap_cool = 0;
fol_last  = { x: 0, y: 0 };

with (obj_plat_solid) visible = other.plat_show_solids;
with (obj_plat_ledge) visible = other.plat_show_solids;

// Kris is invisible but still walks around on the arrow keys: keep him put so he stays in range of the dialogue trigger
with (obj_kris) { move_spd = 0; x = 0; y = 0; }

// --- the two of them ---
var _sx = room_width / 2, _sy = room_height - 64;
if (instance_exists(obj_plat_start)) { _sx = obj_plat_start.x; _sy = obj_plat_start.y; }

var _s = instance_create_depth(_sx, _sy, -100, obj_plat_player);
_s.set_who("susie");
var _r = instance_create_depth(_sx - start_gap, _sy, -90, obj_plat_player);
_r.set_who("ralsei");
party = [_s, _r];
_s.leader = true;

// the trail starts as a straight line from Ralsei to Susie, so he's already "following"
for (var i = 0; i <= follow_delay; i++)
{
    var _k = i / follow_delay;
    array_push(hist, { x: lerp(_r.x, _s.x, _k), y: _sy, g: true, f: 1 });
}
fi = 0;
fol_last = { x: _r.x, y: _r.y };

leader   = function() { return party[leader_i]; }
follower = function() { return party[1 - leader_i]; }

/// C: you take over the other one. the trail flips around so the one you left starts walking after you
swap = function()
{
    var _old = leader(), _new = follower();
    // keep only the stretch between them, reversed: it runs from where the old leader is to where the new one is
    var _seg = [];
    for (var i = array_length(hist) - 1; i >= fi; i--) array_push(_seg, hist[i]);
    hist = _seg;
    fi = 0;

    _old.leader = false;
    _old.vx = 0; _old.vy = 0;
    _new.leader   = true;
    _new.vx       = 0;
    _new.vy       = 0;
    _new.xr = 0; _new.yr = 0;
    _new.grounded = _new.on_ground();
    _new.depth = -100;
    _old.depth = -90;
    leader_i = 1 - leader_i;
    fol_last = { x: _old.x, y: _old.y };
    swap_cool = swap_cool_max;
    if (swap_sound != noone) audio_play_sound(swap_sound, 1, false);
}

/// gameplay starts (called when self_5 closes)
begin_play = function()
{
    global.plat_lock = false;
    state = "play";
}

/// where the camera wants to be
cam_target = function()
{
    var _vw = camera_get_view_width(view_camera[0]);
    var _vh = camera_get_view_height(view_camera[0]);
    var _l  = leader();
    return {
        x: clamp(_l.x - _vw / 2, 0, max(0, room_width - _vw)),
        y: clamp(_l.y - _vh * cam_lead_y, 0, max(0, room_height - _vh))
    };
}

// start the camera on them
var _c = cam_target();
cam_x = _c.x;
cam_y = _c.y;
camera_set_view_pos(view_camera[0], cam_x, cam_y);
if (instance_exists(obj_camera_controller)) { obj_camera_controller.cam_x = cam_x; obj_camera_controller.cam_y = cam_y; }