var _interior = scr_get_box_interior();
var _cx = (_interior.x1 + _interior.x2) / 2;
var _cy = (_interior.y1 + _interior.y2) / 2;
var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _scale_x = _gui_w / camera_get_view_width(view_camera[0]);
var _scale_y = _gui_h / camera_get_view_height(view_camera[0]);

var _qx1 = (safe_quadrant == "tl" || safe_quadrant == "bl") ? _interior.x1 : _cx;
var _qx2 = (safe_quadrant == "tl" || safe_quadrant == "bl") ? _cx : _interior.x2;
var _qy1 = (safe_quadrant == "tl" || safe_quadrant == "tr") ? _interior.y1 : _cy;
var _qy2 = (safe_quadrant == "tl" || safe_quadrant == "tr") ? _cy : _interior.y2;

var _x1 = (_qx1 - _vx) * _scale_x;
var _y1 = (_qy1 - _vy) * _scale_y;
var _x2 = (_qx2 - _vx) * _scale_x;
var _y2 = (_qy2 - _vy) * _scale_y;

draw_set_alpha(alpha);
draw_set_color(c_lime);
draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_alpha(1);