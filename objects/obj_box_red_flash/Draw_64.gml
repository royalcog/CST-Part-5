if (instance_exists(obj_battlebox))
{
    var _interior = scr_get_box_interior();
    var _vx = camera_get_view_x(view_camera[0]);
    var _vy = camera_get_view_y(view_camera[0]);
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _scale_x = _gui_w / camera_get_view_width(view_camera[0]);
    var _scale_y = _gui_h / camera_get_view_height(view_camera[0]);

    var _x1 = round((_interior.x1 - _vx) * _scale_x);
    var _y1 = round((_interior.y1 - _vy) * _scale_y);
    var _x2 = round((_interior.x2 - _vx) * _scale_x);
    var _y2 = round((_interior.y2 - _vy) * _scale_y);

    var _margin = 60; // was 30 — bump up, tune further to taste
    var _margin_x = round(_margin * _scale_x);
    var _margin_y = round(_margin * _scale_y);

    switch (exclude_side)
    {
        case "left":  _x1 += _margin_x; break;
        case "right": _x2 -= _margin_x; break;
        case "up":    _y1 += _margin_y; break;
        case "down":  _y2 -= _margin_y; break;
    }

    draw_set_alpha(alpha);
    draw_set_color(c_red);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1);
}