// a green glow with a fading trail behind it
gpu_set_blendmode(bm_add);
var _n = array_length(trail);
for (var i = 0; i < _n; i++)
{
    var _k = (i + 1) / (_n + 1);
    draw_set_alpha(_k * 0.5);
    draw_set_colour(col);
    draw_circle(trail[i].x, trail[i].y, radius * _k, false);
}
draw_set_alpha(0.6);
draw_set_colour(col);
draw_circle(x, y, radius + 2, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_colour(c_white);
draw_circle(x, y, radius * 0.5, false);