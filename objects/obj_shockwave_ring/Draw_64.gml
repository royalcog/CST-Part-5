var _interior = scr_get_box_interior();
var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _scale_x = _gui_w / camera_get_view_width(view_camera[0]);
var _scale_y = _gui_h / camera_get_view_height(view_camera[0]);

// The expanding ring itself
if (phase == "expanding")
{
    var _sx = (center_x - _vx) * _scale_x;
    var _sy = (center_y - _vy) * _scale_y;
    var _r = radius * _scale_x;

    draw_set_color(c_red);
    draw_set_alpha(0.6);
    draw_circle(_sx, _sy, _r, true);
    draw_set_alpha(1);
}