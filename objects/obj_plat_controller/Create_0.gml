// the tower climb (rm_tower). makes Susie and Ralsei, runs swapping (C) and the follower, moves the camera,
// and opens self_5 once the white flash has faded. you play once self_5 closes.
global.plat_lock     = true;   // no control until self_5 is done
global.cutscene_lock = true;   // Z doesn't open self_ dialogue up here (the climb opens its own)
global.textbox_top   = false;

// --- the climb is spread over a few rooms: how far you've got, and everyone's HP, survive room changes ---
if (!variable_global_exists("plat_progress") || !is_struct(global.plat_progress))
    global.plat_progress = { started: false, flowers: false, halfway: false, intro: false, battle: false };
if (!variable_global_exists("plat_hp") || !is_struct(global.plat_hp))
    global.plat_hp = { susie: 290, ralsei: 210 };
if (!variable_global_exists("plat_entry") || !is_struct(global.plat_entry))
    global.plat_entry = { kind: "start", x: 0, leader: "susie" };
progress = global.plat_progress;

// --- where this room's ends lead (asset_get_index so it still runs before those rooms exist) ---
first_room = (room == rm_tower);
next_room  = first_room ? asset_get_index("rm_tower2") : asset_get_index("rm_tower_top");   // land on something above top_y -> up into here
fall_room  = first_room ? -1 : rm_tower;                       // fall off the bottom -> back down into here
top_room   = asset_get_index("rm_tower_top");                  // Queen's lift (both at 1 HP) -> here
top_y      = 40;
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
    u_amt   = shader_get_uniform(shd_tower_wrap, "u_amt");
}

// --- the fountain's shadow from rm_two carries on up the tower, fading the higher you climb ---
shadow_on       = true;
shadow_strength = 0.75;    // 0-1 at the bottom of rm_tower (rm_two's is 1 at its darkest, right by the fountain)...
shadow_top      = 0;       // ...fading to this at the top of rm_tower2
if (shadow_on && !instance_exists(obj_shadow_tint))
{
    with (instance_create_depth(0, 0, 0, obj_shadow_tint))
    {
        flat        = true;
        tiles_only  = true;            // the ledges and deco, not the Titan Spawn / fish / effects
        strength    = other.shadow_strength;
        back_depth  = 480;             // the tower (TowerBG) and the Background stay as they are
        front_depth = -9000;
        shade_objs  = [obj_plat_player];
    }
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

// --- the two of them: at the start point, or (falling back down from the room above) dropping in from the top ---
var _entry = global.plat_entry;
var _sx = room_width / 2, _sy = room_height - 64, _drop = true;
if (_entry.kind == "fall")
{
    _sx = ((_entry.x mod room_width) + room_width) mod room_width;
    _sy = 10;
    _drop = false;
}
else if (instance_exists(obj_plat_start)) { _sx = obj_plat_start.x; _sy = obj_plat_start.y; }

var _s = instance_create_depth(_sx, _sy, -100, obj_plat_player);
_s.set_who("susie");
var _r = instance_create_depth(_drop ? _sx - start_gap : _sx, _drop ? _sy : _sy - 30, -90, obj_plat_player);
_r.set_who("ralsei");
party = [_s, _r];
leader_i = (_entry.leader == "ralsei") ? 1 : 0;
party[leader_i].leader = true;
party[leader_i].depth = -100;
party[1 - leader_i].depth = -90;
global.plat_entry = { kind: "start", x: 0, leader: _entry.leader };   // used up
// the dark cloud: shows up halfway up rm_tower, then creeps up after you (obj_plat_cloud has its tuning)
cloud_on = true;
if (cloud_on && !instance_exists(obj_plat_cloud))
    with (instance_create_depth(0, 0, -200, obj_plat_cloud)) { mode = "rise"; entry_kind = _entry.kind; }

// both start standing on whatever's under them, not wherever the start point happens to be
if (_drop)
{
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
}

// the trail starts as a straight line from the follower to the leader, so they're already "following"
var _ld0 = party[leader_i], _fl0 = party[1 - leader_i];
for (var i = 0; i <= follow_delay; i++)
{
    var _k = i / follow_delay;
    array_push(hist, { x: lerp(_fl0.x, _ld0.x, _k), y: lerp(_fl0.y, _ld0.y, _k), g: _drop, f: 1 });
}
fi = 0;
fol_last = { x: _fl0.x, y: _fl0.y };

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
// (only in rm_tower; "key" remembers it's been done, even after falling back down from the room above)
triggers = first_room ? [
    { x: 320, y: 2760, r: 24, text: "plat_flowers", key: "flowers", done: progress.flowers },
    { above_y: room_height / 2, text: "plat_halfway", key: "halfway", done: progress.halfway },   // move this to wherever halfway ends up
    { x: 800, y: 560, r: 40, battle: true, key: "battle", done: progress.battle },                // the fight
] : [];

// fights placed by a map ("X" in rm_tower2's)
if (variable_global_exists("plat_extra_triggers"))
{
    for (var i = 0; i < array_length(global.plat_extra_triggers); i++)
    {
        var _xt = global.plat_extra_triggers[i];
        _xt.done = progress[$ _xt.key] ?? false;
        array_push(triggers, _xt);
    }
    global.plat_extra_triggers = [];
}

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
music_fade_in = 2500;    // ms sng_chaostower fades in over
spawn_on      = progress.intro;   // already past the first scene (coming back into a room): straight to the regular ones
spawn_t       = 0;
intro         = progress.intro ? "done" : "";      // spawn -> arrive -> talk -> pause -> attack -> after -> dots -> done
intro_t       = 0;
intro_pairs   = [];      // { hero, spawn, side }

/// called when the halfway chat closes
start_spawning = function()
{
    if (spawn_on) return;
    spawn_on = true;
    intro    = "spawn";
    intro_t  = 0;
    start_tower_music();
}

/// sng_chaostower, fading in (it loops until you reach the top). does nothing if it's already going
start_tower_music = function()
{
    if (variable_global_exists("song") && global.song == sng_chaostower
        && variable_global_exists("music") && global.music != noone && audio_is_playing(global.music)) return;
    global.music      = scr_audio_fade_in(sng_chaostower, music_fade_in, 1, true);
    global.song       = sng_chaostower;
    global.song_start = current_time;
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

// --- the fight at (800, 560) (obj_plat_battle runs it) ---
wrap_amt    = 1;       // how bent the picture is right now (0 = flat)...
wrap_target = 1;       // ...and what it's easing toward
cam_locked  = false;   // the camera stays put while this is on
cam_release = 0;       // frames the camera eases back after the fight
battle_on   = false;
global.plat_arena = undefined;   // the fight's box (players can't leave it)

/// starts a fight (from its trigger). a trigger with vert: true has fish coming down as well as across
start_battle = function(_tr = undefined)
{
    if (battle_on) return;
    battle_on = true;
    progress[$ (_tr != undefined) ? _tr.key : "battle"] = true;
    with (obj_plat_titanspawn) if (!dying) { dying = true; die_t = 0; }   // any regular ones clear off
    var _b = instance_create_depth(0, 0, -200, obj_plat_battle);
    if (_tr != undefined && (_tr[$ "vert"] ?? false)) _b.fish_vert = 0.5;
}

/// the first floor at or below (_x, _y), scanning down to _max_y
find_floor = function(_x, _y, _max_y)
{
    var _l = leader();
    for (var _yy = round(_y); _yy < _max_y; _yy++)
        if (_l.solid_at(_x, _yy + 1) || _l.ledge_under(_x, _yy)) return _yy;
    return _max_y - 20;
}

// --- HP: a hit pops the HP boxes up, drains it, holds a second, then they go away again ---
// nobody goes below 1. once one of them's at 1, hits go to the other; once both are, Queen comes to get them
ui_hold    = 60;      // frames the boxes stay up after the HP's gone down
ui_t       = 0;
ui_pending = false;   // waiting for the boxes to be up before the HP goes down
ui_cam_x   = 0;
rescue_step  = "";
rescue_chair = noone;
rescue_faced = false;

/// a hit on _who for _amount. returns { inst (who actually took it), dealt }
party_damage = function(_who, _amount)
{
    var _hp  = global.plat_hp;
    var _oth = (_who == "susie") ? "ralsei" : "susie";
    var _tgt = (_hp[$ _who] <= 1) ? _oth : _who;   // already at 1: it goes to the other one
    var _old = _hp[$ _tgt];
    _hp[$ _tgt] = max(1, _old - _amount);
    var _dealt = _old - _hp[$ _tgt];
    if (_dealt > 0) show_damage_ui();
    if (_hp.susie <= 1 && _hp.ralsei <= 1) start_rescue();
    return { inst: member(_tgt), dealt: _dealt };
}

/// pops the HP boxes up from the bottom of the screen (they drain once they're up)
show_damage_ui = function()
{
    if (!instance_exists(obj_UI))
    {
        scr_duo_ui_setup(true, global.plat_hp.susie, global.plat_hp.ralsei);   // made with the old HP...
        with (obj_battle_ui_box)
        {
            hp = other.ui_last_hp[$ string_lower(char_name)];
            hp_display = hp;
        }
        obj_UI.active_box = noone;
        obj_UI.ui_hidden  = true;
        obj_UI.hide_y     = obj_UI.hide_drop;   // ...starting below the screen
        ui_cam_x = camera_get_view_x(view_camera[0]);
    }
    obj_UI.ui_hidden = false;
    ui_pending = true;
}

/// what the boxes showed last (so a new hit drains from there)
ui_last_hp = { susie: global.plat_hp.susie, ralsei: global.plat_hp.ralsei };

/// keeps the boxes on screen as the camera moves, drains them once they're up, and hides them again (End Step)
update_damage_ui = function()
{
    if (!instance_exists(obj_UI)) return;
    var _cx = camera_get_view_x(view_camera[0]);
    var _d  = _cx - ui_cam_x;
    ui_cam_x = _cx;
    with (obj_UI) { x += _d; target_x += _d; onscreen_x += _d; offscreen_x += _d; }

    if (ui_pending && obj_UI.hide_y < 8)
    {
        // up: now the HP goes down
        with (obj_battle_ui_box)
        {
            var _k = string_lower(char_name);
            if (hp != global.plat_hp[$ _k]) { hp = global.plat_hp[$ _k]; hurt_timer = hurt_flash_time; }
        }
        ui_last_hp = { susie: global.plat_hp.susie, ralsei: global.plat_hp.ralsei };
        ui_pending = false;
        ui_t = ui_hold + 20;   // a little extra for the drain itself
    }
    else if (!ui_pending && ui_t > 0)
    {
        if (--ui_t <= 0) obj_UI.ui_hidden = true;
    }

    // all the way back down: gone
    if (obj_UI.ui_hidden && !ui_pending && obj_UI.hide_y >= obj_UI.hide_drop - 2)
    {
        with (obj_battle_ui_box) instance_destroy();
        with (obj_UI) instance_destroy();
    }
}

/// both at 1 HP: everything stops, Queen floats down in her chair, and off to the top
start_rescue = function()
{
    if (state == "rescue") return;
    state        = "rescue";
    rescue_step  = "land";
    rescue_faced = false;
    t            = 0;
    global.plat_lock = true;
    spawn_on     = false;
    with (obj_plat_titanspawn) if (!dying) { dying = true; die_t = 0; }
    with (obj_plat_battle) instance_destroy();
    battle_on  = false;
    cam_locked = true;
}

// --- moving between rooms ---
/// fades to black and goes to _room. _kind = how they come in there ("up" = the start point, "fall" = from the top).
/// _music_out = fade the music too (only when leaving the climb)
leave_room = function(_room, _kind, _music_out = false)
{
    if (_room < 0) { show_debug_message("obj_plat_controller: that room doesn't exist yet"); return false; }
    state = "leaving";
    global.plat_lock = true;
    global.plat_entry = { kind: _kind, x: leader().x, leader: leader().who };
    with (obj_cutscenefade) instance_destroy();
    var _f = instance_create_depth(0, 0, -9999, obj_cutscenefade);
    _f.fade_color  = c_black;
    _f.fade_target = 1;
    _f.target_room = _room;
    if (_music_out)
    {
        _f.fade_step = 1 / 60;
        _f.wait_duration = 30;
        _f.old_music_fade_time = 1500;
    }
    else
    {
        _f.fade_step = 1 / 15;
        _f.wait_duration = 6;
        _f.old_music_faded = true;   // the music keeps going into the next room
    }
    return true;
}