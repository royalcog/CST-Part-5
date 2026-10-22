function scr_spawn_gavel_hammer(_safe_quadrant)
{
    var _interior = scr_get_box_interior();
    var _cx = (_interior.x1 + _interior.x2) / 2;
    var _cy = (_interior.y1 + _interior.y2) / 2;
    var _reach = 92 * 2.5;
    var _pivot_y = _cy - _reach;

    var _h = instance_create_depth(_cx, _pivot_y, -220, obj_gavel_hammer);
    _h.safe_quadrant = _safe_quadrant;
    return _h;
}