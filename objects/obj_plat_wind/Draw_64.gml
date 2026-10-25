draw_set_colour(streak_col);
for (var i = 0; i < array_length(streaks); i++)
{
    var _s = streaks[i];
    draw_set_alpha(_s.a);
    draw_line_width(_s.x, _s.y, _s.x - dir * _s.len, _s.y, 2);
}
draw_set_alpha(1);