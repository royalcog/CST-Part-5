var _mx = scr_plat_draw_x(x);
var _gr = dot_r * 2 + sin(pulse) * 1.5;
for (var i = 0; i < count; i++)
{
    var _a  = ang + i * 360 / count;
    var _px = _mx + lengthdir_x(radius, _a);
    var _py = y + lengthdir_y(radius, _a);
    draw_set_alpha(glow);
    draw_circle_colour(_px, _py, _gr, c_white, c_white, false);
    draw_set_alpha(1);
    draw_circle_colour(_px, _py, dot_r, c_white, c_white, false);
}