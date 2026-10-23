// the tower climb (rm_tower). makes Susie and Ralsei, runs swapping (C) and the follower, moves the camera,
// and opens self_5 once the white flash has faded. you play once self_5 closes.
global.plat_lock     = true;   // no control until self_5 is done
global.cutscene_lock = true;   // Z doesn't open self_ dialogue up here (the climb opens its own)
global.textbox_top   = false;
// --- the platforms wrap around the tower ---
// the room's width is the tower's circumference: run off one side and you come back on the other,
// and the whole picture gets bent around a cylinder (Post Draw)
wrap_on    = true;       // false: back to a flat climb
wrap_shade = 0.55;       // how much darker the tower gets toward its edges
global.plat_wrap_w = wrap_on ? room_width : 0;
wrap_r     = room_width / (2 * pi);   // the tower's radius on screen (so the front isn't stretched or squashed)

if (wrap_on)
{
    // every tile layer gets copies one tower-width to each side, for the seam
    var _layers = layer_get_all();
    for (var i = 0; i < array_length(_layers); i++)
    {
        var _tm = layer_tilemap_get_id(_layers[i]);
        if (_tm == -1) continue;
        with (instance_create_depth(0, 0, layer_get_depth(_layers[i]), obj_plat_wrapcopy)) tm = _tm;
    }

    application_surface_draw_enable(false);   // Post Draw draws it instead, bent around the tower
    u_cx    = shader_get_uniform(shd_tower_wrap, "u_cx");
    u_r     = shader_get_uniform(shd_tower_wrap, "u_r");
    u_span  = shader_get_uniform(shd_tower_wrap, "u_span");
    u_shade = shader_get_uniform(shd_tower_wrap, "u_shade");
}

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
    _old.attacking = false;
    _old.hurt_t = 0;
    _old.image_yscale = 2;
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
        x: wrap_on ? _l.x - _vw / 2 : clamp(_l.x - _vw / 2, 0, max(0, room_width - _vw)),
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
                    var _cx = floor((scr_plat_wrap(_px) - _ox) / _tw);
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

// every textbox in here is the climb's special one (up top, no box, just a shadow)
global.textbox_plat = true;

// --- dialogue triggers: reach one and its text opens (once), while you keep playing ---
//  { x, y, r }:  fires when either of them gets within r px of that point
//  { above_y }:  fires when either of them climbs above that height
triggers = [
    { x: 320, y: 2760, r: 24, text: "plat_flowers", done: false },
    { above_y: room_height / 2, text: "plat_halfway", done: false },   // move this to wherever halfway ends up
];

/// the first trigger anyone's touching, or undefined
trigger_hit = function()
{
    for (var i = 0; i < array_length(triggers); i++)
    {
        var _tr = triggers[i];
        if (_tr.done) continue;
        for (var p = 0; p < array_length(party); p++)
        {
            var _c = party[p];
            if (variable_struct_exists(_tr, "above_y"))
            {
                if (_c.y <= _tr.above_y) return _tr;
            }
            else
            {
                var _tx = _c.x + scr_plat_wrap_dx(_c.x, _tr.x);   // the trigger, on this side of the tower
                if (point_in_rectangle(_tx, _tr.y, _c.x - _c.hw - _tr.r, _c.y - _c.hh - _tr.r, _c.x + _c.hw + _tr.r, _c.y + _tr.r))
                    return _tr;
            }
        }
    }
    return undefined;
}

/// whichever of them is _who ("susie" / "ralsei")
member = function(_who)
{
    for (var i = 0; i < array_length(party); i++) if (party[i].who == _who) return party[i];
    return noone;
}

/// for the halfway chat: if Susie's the one following, she turns to face Ralsei (and holds it a while)
susie_turn = function(_hold = 240)
{
    var _s = member("susie");
    if (_s == noone || _s.leader) return;
    var _r = member("ralsei");
    _s.face = (scr_plat_wrap_dx(_s.x, _r.x) >= 0) ? 1 : -1;
    _s.face_hold = _hold;
}

// --- Titan Spawn ---
// none until the halfway chat is over. then a little scene: one comes in fast from each side and slows down
// behind whoever's on that side, they turn and take theirs out in one hit, and the other one goes "...".
// after that they come every spawn_every frames
spawn_every   = 300;     // frames between new ones (5s)
spawn_max     = 2;       // most on screen at once
spawn_margin  = 60;      // px outside the screen they appear
intro_hold    = 110;     // px from each hero the first two stop and hover
intro_pause   = 60;      // frames after "Watch out!" before they attack
intro_after   = 60;      // frames after they're gone before the "..."
spawn_on      = false;
spawn_t       = 0;
intro         = "";      // spawn -> arrive -> talk -> pause -> attack -> after -> dots -> done
intro_t       = 0;
intro_pairs   = [];      // { hero, spawn, side }

/// called when the halfway chat closes
start_spawning = function()
{
    if (spawn_on) return;
    spawn_on = true;
    intro    = "spawn";
    intro_t  = 0;
}

/// one of the two scene spawns: comes in from _side (-1 left, 1 right) of _hero, fast, then slows down behind them
make_intro_spawn = function(_hero, _side)
{
    var _w  = scr_plat_wrap_w();
    var _vw = camera_get_view_width(view_camera[0]);
    var _x  = (_w > 0) ? _hero.x + _side * _w * 0.32 : _hero.x + _side * (_vw / 2 + spawn_margin + 40);
    var _y  = _hero.y - _hero.hh / 2 + random_range(-30, 10);
    var _s  = instance_create_depth(scr_plat_wrap(_x), _y, -150, obj_plat_titanspawn);
    _s.scripted    = true;
    _s.target_hero = _hero;
    _s.hold_side   = _side;
    _s.hold_dist   = intro_hold;
    return { hero: _hero, spawn: _s, side: _side };
}

/// are all the scene spawns gone (or on their way out)?
intro_spawns_gone = function()
{
    for (var i = 0; i < array_length(intro_pairs); i++)
    {
        var _s = intro_pairs[i].spawn;
        if (instance_exists(_s) && !_s.dying) return false;
    }
    return true;
}

/// a new Titan Spawn: round the back of the tower (it floats around into view), or from above, in front of you
spawn_titan = function(_from_above = false)
{
    var _l  = leader();
    var _vh = camera_get_view_height(view_camera[0]);
    var _w  = scr_plat_wrap_w();
    var _x, _y;

    if (!_from_above)
    {
        var _side = choose(-1, 1);
        if (_w > 0) _x = _l.x + _side * _w * 0.32;
        else        _x = cam_x + camera_get_view_width(view_camera[0]) / 2 + _side * (camera_get_view_width(view_camera[0]) / 2 + spawn_margin);
        _y = cam_y + random_range(40, _vh * 0.6);
    }
    else
    {
        _x = _l.x + random_range(-120, 120);
        _y = cam_y - spawn_margin - 20;
    }
    return instance_create_depth(scr_plat_wrap(_x), _y, -150, obj_plat_titanspawn);
}