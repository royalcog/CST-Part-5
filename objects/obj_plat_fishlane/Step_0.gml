var _vw = camera_get_view_width(view_camera[0]);
var _my = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) / 2;
if (abs(floor_y - _my) > near) { t = every - first; exit; }
if (++t < every) exit;
t = 0;

var _dir = choose(-1, 1);
var _f = instance_create_depth(0, 0, -140, obj_plat_titanfish);
_f.arena  = { cx: scr_plat_wrap(camera_get_view_x(view_camera[0]) + _vw / 2) };
_f.dir    = _dir;
_f.spd    = fish_spd;
_f.scale  = scale;
_f.y0     = floor_y - (sprite_get_height(spr_titanfish_body) / 2) * scale - 2;
_f.warn_t = warn;
_f.ox     = -_dir * (_vw / 2 + 40);