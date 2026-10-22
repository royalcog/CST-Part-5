var _interior = scr_get_flash_bounds();
var _p1 = scr_room_to_gui(_interior.x1, _interior.y1);
var _p2 = scr_room_to_gui(_interior.x2, _interior.y2);

var _x1, _y1, _x2, _y2;
if (orientation == "vertical")
{
    var _cx = scr_room_to_gui(world_pos, 0).x;
    _x1 = _cx - (thickness * _p1.sx) / 2;
    _x2 = _cx + (thickness * _p1.sx) / 2;
    _y1 = _p1.y;
    _y2 = _p2.y;
}
else
{
    var _cy = scr_room_to_gui(0, world_pos).y;
    _y1 = _cy - (thickness * _p1.sy) / 2;
    _y2 = _cy + (thickness * _p1.sy) / 2;
    _x1 = _p1.x;
    _x2 = _p2.x;
}

draw_set_alpha(alpha * 0.5);
draw_set_color(c_red);
draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_alpha(1);