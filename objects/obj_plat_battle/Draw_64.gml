// the dark box around the screen (in GUI space, so it's on top of the bent picture)
if (fade <= 0) exit;
var _w = display_get_gui_width(), _h = display_get_gui_height();
var _l = margin, _r = _w - margin;
var _t = arena.t - cam_y0, _b = min(_h, arena.b - cam_y0 + 2);

// outside the box: dark
draw_set_colour(c_black);
draw_set_alpha(shade_out * fade);
draw_rectangle(0, 0, _w, _t, false);
draw_rectangle(0, _b, _w, _h, false);
draw_rectangle(0, _t, _l, _b, false);
draw_rectangle(_r, _t, _w, _b, false);
draw_set_alpha(1);

// a soft shadow just inside its edges
var _a = shade_in * fade, _d = shade_in_w;
draw_primitive_begin(pr_trianglelist);
// left
draw_vertex_colour(_l, _t, c_black, _a);      draw_vertex_colour(_l + _d, _t, c_black, 0); draw_vertex_colour(_l, _b, c_black, _a);
draw_vertex_colour(_l + _d, _t, c_black, 0);  draw_vertex_colour(_l + _d, _b, c_black, 0); draw_vertex_colour(_l, _b, c_black, _a);
// right
draw_vertex_colour(_r - _d, _t, c_black, 0);  draw_vertex_colour(_r, _t, c_black, _a);     draw_vertex_colour(_r - _d, _b, c_black, 0);
draw_vertex_colour(_r, _t, c_black, _a);      draw_vertex_colour(_r, _b, c_black, _a);     draw_vertex_colour(_r - _d, _b, c_black, 0);
// top
draw_vertex_colour(_l, _t, c_black, _a);      draw_vertex_colour(_r, _t, c_black, _a);     draw_vertex_colour(_l, _t + _d, c_black, 0);
draw_vertex_colour(_r, _t, c_black, _a);      draw_vertex_colour(_r, _t + _d, c_black, 0); draw_vertex_colour(_l, _t + _d, c_black, 0);
draw_primitive_end();

// the outline
draw_set_colour(box_col);
draw_set_alpha(fade);
for (var i = 0; i < box_th; i++) draw_rectangle(_l - i, _t - i, _r + i, _b + i, true);
draw_set_alpha(1);
draw_set_colour(c_white);