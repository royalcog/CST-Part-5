/// the tower climb wraps around the tower: going off one side of rm_tower brings you back in on the other.
/// global.plat_wrap_w is the tower's circumference in room px (obj_plat_controller sets it to room_width; 0 = off)

/// the circumference (0 = not wrapping)
function scr_plat_wrap_w()
{
    return variable_global_exists("plat_wrap_w") ? global.plat_wrap_w : 0;
}

/// _x moved back into [0, circumference)
function scr_plat_wrap(_x)
{
    var _w = scr_plat_wrap_w();
    if (_w <= 0) return _x;
    return ((_x mod _w) + _w) mod _w;
}

/// the shortest way from _a to _b around the tower (negative = to the left)
function scr_plat_wrap_dx(_a, _b)
{
    var _d = _b - _a;
    var _w = scr_plat_wrap_w();
    if (_w <= 0) return _d;
    _d = ((_d mod _w) + _w) mod _w;
    if (_d > _w / 2) _d -= _w;
    return _d;
}

/// where to draw something at _x: whichever copy of it is closest to the middle of the screen
function scr_plat_draw_x(_x)
{
    if (scr_plat_wrap_w() <= 0) return _x;
    var _c = camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) / 2;
    return _c + scr_plat_wrap_dx(_c, _x);
}