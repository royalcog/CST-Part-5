// broken dotted trail showing the path the scissors are catching up
// along, same visual as attack2's scissors sub-attack
if (array_length(trail_points) > 0)
{
    draw_set_color(c_white);
    draw_set_alpha(0.5);
    for (var _i = 0; _i < array_length(trail_points); _i++)
    {
        var _pt = trail_points[_i];
        var _p = scr_room_to_gui(_pt.x, _pt.y);
        draw_circle(_p.x, _p.y, 3, false);
    }
    draw_set_alpha(1);
}