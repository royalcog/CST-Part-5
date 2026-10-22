var _p = 0.75 + 0.25 * sin(t * 0.2);
var _h = y2 - y1;

gpu_set_blendmode(bm_add);
draw_set_color(color);

// glow fill
draw_set_alpha(alpha * 0.22 * _p);
draw_rectangle(x1, y1, x2, y2, false);

// bands sweeping through it
draw_set_alpha(alpha * 0.25);
for (var k = 0; k < 4; k++)
{
    var _yy = y1 + ((t * 1.5 + k * _h / 4) mod _h);
    draw_line_width(x1, _yy, x2, _yy, 2);
}

// bright edges
draw_set_alpha(alpha * 0.9 * _p);
draw_line_width(x1, y1, x2, y1, 3);
draw_line_width(x1, y2, x2, y2, 3);
draw_line_width(x1, y1, x1, y2, 3);
draw_line_width(x2, y1, x2, y2, 3);

draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);