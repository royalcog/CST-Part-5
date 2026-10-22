function scr_spawn_falling_hammer(_x)
{
    var _interior = scr_get_box_interior();
    var _start_y = _interior.y1 - 150;
    return instance_create_depth(_x, _start_y, -220, obj_falling_hammer); // was -180
}