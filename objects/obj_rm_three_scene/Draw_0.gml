// layered: the backdrop's own object at the very back, then the tower and hand, then the laser on top of them,
// with the backdrop's linework cut out of the laser so it looks like it's going down behind the castle

var _cam = view_camera[0];
var _vx  = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
var _vw  = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);

var _hx = mini_x + mini_w / 2 - 3;
var _hy = mini_hand_y;

// ---------------------------------------------------------------- 1. the tower and the hand
var _ts = mini_w / sprite_get_width(spr_titantower_piece);
var _th = sprite_get_height(spr_titantower_piece) * _ts;
for (var _y = mini_base_y; _y > town_top - _th; _y -= _th)
{
    draw_sprite_ext(spr_titantower_piece,    0, mini_x, _y - _th / 2, _ts, _ts, 0, c_white, 1);
    draw_sprite_ext(spr_titantower_gradient, 0, mini_x, _y - _th / 2, _ts, _ts, 0, c_white, 1);
}
draw_sprite_ext(spr_tower_titanhand, mini_hand_frame, _hx, _hy, mini_scale, mini_scale, 0, c_white, 1);

// ---------------------------------------------------------------- 2. the tiny laser, onto its own surface
if (!surface_exists(laser_surf) || surface_get_width(laser_surf) != _vw || surface_get_height(laser_surf) != _vh)
{
    if (surface_exists(laser_surf)) surface_free(laser_surf);
    laser_surf = surface_create(_vw, _vh);
}
surface_set_target(laser_surf);
draw_clear_alpha(c_black, 0);

// from the palm (same spot as the close-up, scaled down) to around the other fountain, cut off there.
// everything here is in surface space (minus the view's corner); drawn by corner, so the beam origins don't matter
var _sx  = _hx + 432 * mini_scale / 2;
var _sy  = _hy - 80 * mini_scale / 2;
var _len = point_distance(_sx, _sy, mini_laser_end_x, mini_laser_end_y);
var _dir = point_direction(_sx, _sy, mini_laser_end_x, mini_laser_end_y);
var _ang = _dir - 270;                                         // the sprites point down
var _dx  = lengthdir_x(1, _dir), _dy = lengthdir_y(1, _dir);   // along the beam
var _nx  = lengthdir_x(1, _ang), _ny = lengthdir_y(1, _ang);   // across it
var _s   = mini_beam_scale;
var _bi  = floor(anim_t / 2) mod sprite_get_number(spr_titanbeam_loop);
var _ox  = _sx - _vx, _oy = _sy - _vy;
var _d   = 0;

var _lw = sprite_get_width(spr_titanbeam_loop), _lh = sprite_get_height(spr_titanbeam_loop);
var _ph = min(_lh, _len / _s);
draw_sprite_general(spr_titanbeam_loop, _bi, 0, 0, _lw, _ph,
                    _ox - _nx * (_lw / 2) * _s, _oy - _ny * (_lw / 2) * _s,
                    _s, _s, _ang, c_white, c_white, c_white, c_white, 1);
_d += _ph * _s;

var _mw = sprite_get_width(spr_titanbeam_midsection), _mh = sprite_get_height(spr_titanbeam_midsection);
var _mi = _bi mod sprite_get_number(spr_titanbeam_midsection);
while (_d < _len)
{
    var _p = min(_mh, (_len - _d) / _s);
    draw_sprite_general(spr_titanbeam_midsection, _mi, 0, 0, _mw, _p,
                        _ox + _dx * _d - _nx * (_mw / 2) * _s, _oy + _dy * _d - _ny * (_mw / 2) * _s,
                        _s, _s, _ang, c_white, c_white, c_white, c_white, 1);
    _d += _p * _s;
}

// cut the backdrop's linework (everything but its pure black) out of the laser
if (town != noone)
{
    var _spr = town.sprite_index;
    var _txs = town.image_xscale, _tys = town.image_yscale;
    var _tl  = town.x - sprite_get_xoffset(_spr) * _txs;   // the backdrop's top-left in the room
    var _tt  = town.y - sprite_get_yoffset(_spr) * _tys;

    var _pad = 60;
    var _l = min(_sx, mini_laser_end_x) - _pad, _r = max(_sx, mini_laser_end_x) + _pad;
    var _t = min(_sy, mini_laser_end_y) - _pad, _b = max(_sy, mini_laser_end_y) + _pad;

    var _pl = clamp((_l - _tl) / _txs, 0, sprite_get_width(_spr));
    var _pt = clamp((_t - _tt) / _tys, 0, sprite_get_height(_spr));
    var _pr = clamp((_r - _tl) / _txs, 0, sprite_get_width(_spr));
    var _pb = clamp((_b - _tt) / _tys, 0, sprite_get_height(_spr));

    if (_pr > _pl && _pb > _pt)
    {
        shader_set(shd_black_key);
        shader_set_uniform_f(u_bg_key, bg_key_threshold);
        gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);   // erases the laser wherever a linework pixel lands
        draw_sprite_part_ext(_spr, town.image_index, _pl, _pt, _pr - _pl, _pb - _pt,
                             _tl + _pl * _txs - _vx, _tt + _pt * _tys - _vy, _txs, _tys, c_white, 1);
        gpu_set_blendmode(bm_normal);
        shader_reset();
    }
}
surface_reset_target();

// ---------------------------------------------------------------- 3. the laser, in front of the tower and hand
draw_surface(laser_surf, _vx, _vy);