var _cy = camera_get_view_y(view_camera[0]);
var _vt = _cy - 20;
var _vb = min(base_bottom_y, _vt + camera_get_view_height(view_camera[0]) + 40);
var _sc = pillar_w / sprite_get_width(spr_titantower_piece);
var _anchor = base_bottom_y + _cy * (1 - parallax);   // parallax < 1: the stonework scrolls slower than the camera

draw_column(spr_titantower_piece,    0, _anchor, _vt, _vb, _sc);
draw_column(spr_titantower_gradient, 0, _anchor, _vt, _vb, _sc);

// darker toward its base
if (tower_shade > 0)
{
    var _hw = pillar_w / 2, _y0 = base_bottom_y - tower_shade_h;
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(fx - _hw, _y0,           c_black, 0);
    draw_vertex_colour(fx + _hw, _y0,           c_black, 0);
    draw_vertex_colour(fx - _hw, base_bottom_y, c_black, tower_shade);
    draw_vertex_colour(fx + _hw, base_bottom_y, c_black, tower_shade);
    draw_primitive_end();
}