if (state == "gone") exit;
var _dx = scr_plat_draw_x(cx) - half;
var _dy = top;
var _a  = 1;
if (state == "shake")     _dx += ((t div 2) mod 2 == 0 ? 2 : -2) * min(1, t / 10);
else if (state == "fall") { var _k = t / fall_len; _dy += 160 * _k * _k; _a = 1 - _k; }
else if (state == "back") _a = t / 20;

draw_set_alpha(_a);

// the tiles, with the same shadow as the ledges (does nothing if there's no shadow)
scr_shadow_tint_begin();
for (var i = 0; i < tiles; i++)
{
    var _tile = (tiles == 1) ? 7 : ((i == 0) ? 6 : ((i == tiles - 1) ? 8 : 7));
    draw_tile(tlst_flowergarden, _tile, 0, _dx + i * 40, _dy);
}
if (instance_exists(obj_shadow_tint)) scr_shadow_tint_end();

// cracks, so you can tell it's not a normal ledge. after the shadow's off: lines aren't textured,
// and drawing them through the shadow shader is what crashed ("invalid input layout")
draw_set_colour(crack_col);
for (var i = 0; i < tiles; i++)
{
    var _tx = _dx + i * 40;
    draw_line_width(_tx + 6,  _dy + 4,  _tx + 16, _dy + 12, 2);
    draw_line_width(_tx + 16, _dy + 12, _tx + 24, _dy + 6,  2);
    draw_line_width(_tx + 24, _dy + 6,  _tx + 34, _dy + 14, 2);
}
draw_set_colour(c_white);
draw_set_alpha(1);