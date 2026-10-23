// the climb wraps around the tower: its stonework fills the whole picture and turns as you go around
// (it repeats a whole number of times around the tower, so the seam doesn't show)
var _wrap = variable_global_exists("plat_wrap_w") ? global.plat_wrap_w : 0;
if (_wrap > 0)
{
    var _n  = max(1, round(_wrap / (sprite_get_width(spr_titantower_piece) * 2)));
    var _sx = _wrap / _n / sprite_get_width(spr_titantower_piece);
    draw_sprite_tiled_ext(spr_titantower_piece, 0, 0, 0, _sx, 2, c_white, 1);
    exit;
}

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