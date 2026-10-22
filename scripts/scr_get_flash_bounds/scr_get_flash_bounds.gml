function scr_get_flash_bounds()
{
    if (instance_exists(obj_battlebox) && obj_battlebox.visible)
    {
        return scr_get_box_interior();
    }

    var _view_x = camera_get_view_x(view_camera[0]);
    var _view_y = camera_get_view_y(view_camera[0]);
    var _view_w = camera_get_view_width(view_camera[0]);
    var _view_h = camera_get_view_height(view_camera[0]);

    return {
        x1: _view_x,
        y1: _view_y,
        x2: _view_x + _view_w,
        y2: _view_y + _view_h
    };
}