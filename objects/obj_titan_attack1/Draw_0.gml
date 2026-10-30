event_inherited();

// a spade's lane, flashing just before it comes in: a line straight across the box at its height, an arrow on its side
if (!instance_exists(obj_battlebox)) exit;
var _in = scr_get_box_interior();
for (var i = 0; i < array_length(warnings); i++)
{
    var _wn = warnings[i];
    var _a  = ((_wn.t div 4) mod 2 == 0) ? 0.8 : 0.3;   // blinking
    var _p1 = scr_box_local_to_world(_in.x1, _wn.ly);
    var _p2 = scr_box_local_to_world(_in.x2, _wn.ly);
    draw_set_colour(warn_col);
    draw_set_alpha(_a);
    draw_line_width(_p1.x, _p1.y, _p2.x, _p2.y, warn_width);
    // the arrow, just inside the side it's coming from, pointing the way it'll go
    var _ex = (_wn.side == -1) ? _in.x1 + 10 : _in.x2 - 10;
    var _d  = -_wn.side;
    var _tip = scr_box_local_to_world(_ex + _d * 6, _wn.ly);
    var _b1  = scr_box_local_to_world(_ex - _d * 4, _wn.ly - 6);
    var _b2  = scr_box_local_to_world(_ex - _d * 4, _wn.ly + 6);
    draw_triangle(_tip.x, _tip.y, _b1.x, _b1.y, _b2.x, _b2.y, false);
}
draw_set_alpha(1);
draw_set_colour(c_white);