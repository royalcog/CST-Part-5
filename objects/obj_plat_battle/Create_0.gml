// the fight at (880, 1200): the camera stops, a dark box closes in around the screen and you can't leave it.
// a big Titan Spawn flies around; the one you're controlling has to hit it 7 times. now and then it glows
// rainbow and can't be hit, and Titan fish keep swimming through just above the floor (jump over them).
// made by obj_plat_controller.start_battle()
ctl = instance_find(obj_plat_controller, 0);

// --- tuning ---
keep_wrap       = false;   // true: the tower stays bent during the fight. false: it flattens out (easier to read)
margin          = 40;      // px in from the sides of the screen you can go
top_margin      = 8;
fade_len        = 40;      // frames the box fades in/out over
box_col         = make_color_rgb(40, 10, 60);   // the box's outline
box_th          = 3;
shade_out       = 0.75;    // how dark it is outside the box
shade_in        = 0.45;    // the soft shadow just inside its edges...
shade_in_w      = 36;      // ...this many px deep

boss_hits       = 7;       // hits to win
rainbow_at      = [2, 4, 6];   // it glows rainbow (can't be hit) after this many hits...
rainbow_len     = 480;     // ...for this many frames (8s)
no_rainbow_after = 55 * 60;    // past this many frames, it stops going rainbow (so the fight doesn't drag)
rainbow_sound   = snd_sparklegem;

fish_first      = 150;     // frames into the fight before the first fish
fish_every      = 210;     // frames between fish normally (3.5s)...
fish_every_rb   = 120;     // ...and while it's rainbow (2s)
fish_warn       = 54;      // frames the "!" shows at the edge before it comes in
fish_scale      = 1.5;
fish_speed      = 7.5;     // fast enough to clear in one jump toward it
fish_vert       = 0;       // chance (0-1) each fish comes up/down through the arena instead of across
fish_vert_speed = 6.5;
fish_vert_warn  = 60;      // frames the "!" shows at the top/bottom first
vert_gap        = 220;     // two up/down fish at once are at least this far apart (room to stand between)
pair_slow       = 1.25;    // pairs come this much less often than single fish

end_wait        = 40;      // frames after it's gone before the box opens back up

// --- set up the arena: the screen as it is right now ---
var _vw = camera_get_view_width(view_camera[0]);
var _vh = camera_get_view_height(view_camera[0]);
cam_x0 = camera_get_view_x(view_camera[0]);
cam_y0 = camera_get_view_y(view_camera[0]);
ctl.cam_locked  = true;
ctl.wrap_target = keep_wrap ? 1 : 0;
global.plat_lock = true;   // a moment to take it in

var _l  = ctl.leader();
floor_y = ctl.find_floor(_l.x, _l.y, cam_y0 + _vh);
arena = {
    cx:   scr_plat_wrap(cam_x0 + _vw / 2),
    half: _vw / 2 - margin,
    t:    cam_y0 + top_margin,
    b:    floor_y
};
global.plat_arena = arena;
fish_y = floor_y - (sprite_get_height(spr_titanfish_body) / 2) * fish_scale - 2;   // just above the floor

// --- state ---
state    = "intro";   // intro -> fight -> end
t        = 0;
fade     = 0;
fight_t  = 0;
boss     = noone;
ri       = 0;         // which rainbow_at is next
rainbow_t = 0;
fish_t   = 0;

/// a fish coming in from _dir's side (1 = from the left, heading right)
spawn_fish = function(_dir)
{
    var _f = instance_create_depth(0, 0, -140, obj_plat_titanfish);
    _f.owner  = id;
    _f.arena  = arena;
    _f.cam_y0 = cam_y0;
    _f.dir    = _dir;
    _f.spd    = fish_speed;
    _f.scale  = fish_scale;
    _f.y0     = fish_y;
    _f.warn_t = fish_warn;
    _f.ox     = -_dir * (camera_get_view_width(view_camera[0]) / 2 + 40);
    return _f;
}

/// a fish coming down (_dir 1) or up (_dir -1) through the arena at _ox across (random if not given)
spawn_fish_vert = function(_dir, _ox = undefined)
{
    var _vh = camera_get_view_height(view_camera[0]);
    var _f = instance_create_depth(0, 0, -140, obj_plat_titanfish);
    _f.owner  = id;
    _f.arena  = arena;
    _f.cam_y0 = cam_y0;
    _f.vert   = true;
    _f.dir    = _dir;
    _f.spd    = fish_vert_speed;
    _f.scale  = fish_scale;
    _f.warn_t = fish_vert_warn;
    _f.ox     = (_ox != undefined) ? _ox : random_range(-arena.half + 40, arena.half - 40);
    _f.oy     = (_dir > 0) ? cam_y0 - 40 : cam_y0 + _vh + 40;
    return _f;
}