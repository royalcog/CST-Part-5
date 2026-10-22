function scr_get_gui_scale()
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _cam = view_camera[0];
    return {
        vx: camera_get_view_x(_cam),
        vy: camera_get_view_y(_cam),
        vw: camera_get_view_width(_cam),
        vh: camera_get_view_height(_cam),
        angle: camera_get_view_angle(_cam),
        sx: _gui_w / camera_get_view_width(_cam),
        sy: _gui_h / camera_get_view_height(_cam)
    };
}

function scr_room_to_gui(_x, _y)
{
    var _g = scr_get_gui_scale();

    var _cx = _g.vx + _g.vw / 2;
    var _cy = _g.vy + _g.vh / 2;

    // un-rotate the point around the view's center by the camera's current
    // angle before applying the usual translate/scale — same technique as
    // scr_world_to_box_local, just for the camera's own rotation instead of
    // the box's. Keeps anything drawn manually in GUI space (hand punches,
    // strip flashes, the lighting cutout, etc.) lined up with what the
    // camera renders normally even while the view is rotated (e.g. during
    // Friend's screen-flip attack).
    var _rel = scr_rotate_point(_x - _cx, _y - _cy, -_g.angle);

    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();

    return {
        x: _gui_w / 2 + _rel.x * _g.sx,
        y: _gui_h / 2 + _rel.y * _g.sy,
        sx: _g.sx,
        sy: _g.sy,
        angle: _g.angle
    };
}