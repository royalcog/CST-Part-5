var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _scale_x = _gui_w / camera_get_view_width(view_camera[0]);
var _scale_y = _gui_h / camera_get_view_height(view_camera[0]);

var _x1 = round((x - _vx) * _scale_x);
var _y1 = round((y - _vy) * _scale_y);
var _x2 = round((x + cell_w - _vx) * _scale_x);
var _y2 = round((y + cell_h - _vy) * _scale_y);

draw_set_alpha(alpha);
draw_set_color(c_yellow);
draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_alpha(1);