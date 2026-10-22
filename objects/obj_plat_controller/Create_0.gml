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

// both start standing on whatever's under them, not wherever the start point happens to be
for (var p = 0; p < 2; p++)
{
    var _c = party[p];
    repeat (600)
    {
        if (_c.on_ground()) break;
        _c.y += 1;
    }
    _c.grounded = _c.on_ground();
}

// the trail starts as a straight line from Ralsei to Susie, so he's already "following"
for (var i = 0; i <= follow_delay; i++)
{
    var _k = i / follow_delay;
    array_push(hist, { x: lerp(_r.x, _s.x, _k), y: lerp(_r.y, _s.y, _k), g: true, f: 1 });
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


// --- tiles that change while someone's standing on/in them (the flower garden) ---
press_layers = ["Tiles_Solid", "Tiles_Ledge", "Tiles_Deco"];   // layers to check (missing ones are skipped)
press_tiles  = [6, 7, 8, 12, 13, 14, 18, 19, 20];
press_shift  = 3;
pressed      = {};      // "tilemap:col:row" -> what that tile was, to put it back

press_maps = [];
for (var i = 0; i < array_length(press_layers); i++)
    if (layer_exists(press_layers[i])) array_push(press_maps, layer_tilemap_get_id(layer_get_id(press_layers[i])));

/// swaps the tiles under anyone standing on them, and puts back the ones nobody's on anymore
update_pressed = function()
{
    var _now = {};
    for (var p = 0; p < array_length(party); p++)
    {
        var _c = party[p];
        if (!instance_exists(_c) || !_c.grounded) continue;

        for (var m = 0; m < array_length(press_maps); m++)
        {
            var _tm = press_maps[m];
            var _tw = tilemap_get_tile_width(_tm),  _th = tilemap_get_tile_height(_tm);
            var _ox = tilemap_get_x(_tm),           _oy = tilemap_get_y(_tm);
            var _r  = _c.x + _c.hw - 1;

            // across their feet: the tile they're standing on (y) and the one their feet are in (y - 1)
            for (var _px = _c.x - _c.hw; ; _px = min(_px + _tw, _r))
            {
                for (var k = 0; k < 2; k++)
                {
                    var _cx = floor((_px - _ox) / _tw);
                    var _cy = floor((_c.y - k - _oy) / _th);
                    var _key = string(_tm) + ":" + string(_cx) + ":" + string(_cy);
                    if (variable_struct_exists(pressed, _key)) { _now[$ _key] = true; continue; }

                    var _data = tilemap_get(_tm, _cx, _cy);
                    var _idx  = tile_get_index(_data);
                    if (_idx != 0 && array_contains(press_tiles, _idx))
                    {
                        tilemap_set(_tm, tile_set_index(_data, _idx + press_shift), _cx, _cy);
                        pressed[$ _key] = { tm: _tm, cx: _cx, cy: _cy, data: _data };
                        _now[$ _key] = true;
                    }
                }
                if (_px >= _r) break;
            }
        }
    }

    // nobody's on these anymore: back to normal
    var _keys = variable_struct_get_names(pressed);
    for (var i = 0; i < array_length(_keys); i++)
    {
        if (variable_struct_exists(_now, _keys[i])) continue;
        var _p = pressed[$ _keys[i]];
        tilemap_set(_p.tm, _p.data, _p.cx, _p.cy);
        variable_struct_remove(pressed, _keys[i]);
    }
}