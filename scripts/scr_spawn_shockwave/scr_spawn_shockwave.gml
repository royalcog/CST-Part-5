function scr_spawn_shockwave(_safe_quadrant)
{
    var _interior = scr_get_box_interior();
    var _cx = (_interior.x1 + _interior.x2) / 2;
    var _cy = (_interior.y1 + _interior.y2) / 2;

    var _r = instance_create_depth(_cx, _cy, -390, obj_shockwave_ring);
    _r.safe_quadrant = _safe_quadrant;
    return _r;
}