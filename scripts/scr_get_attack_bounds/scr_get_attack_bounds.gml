function scr_get_attack_bounds()
{
    if (instance_exists(obj_battlebox) && obj_battlebox.visible)
    {
        return scr_get_box_interior();
    }

    var _view_x = camera_get_view_x(view_camera[0]);
    var _view_y = camera_get_view_y(view_camera[0]);
    var _view_w = camera_get_view_width(view_camera[0]);
    var _view_h = camera_get_view_height(view_camera[0]);
    var _margin = 40; // stay a bit inset from the actual screen edge

    return {
        x1: _view_x + _margin,
        y1: _view_y + _margin,
        x2: _view_x + _view_w - _margin,
        y2: _view_y + _view_h - _margin
    };
}