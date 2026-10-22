if (state != "windup" || (timer div 6) mod 2 != 0) exit;

// blinking red line exactly where the beam will appear, cut off at the box walls
var _in = scr_get_box_interior();
var _ang = obj_battlebox.box_angle;
var _dx = lengthdir_x(1, beam_angle);
var _dy = lengthdir_y(1, beam_angle);
var _lx = lengthdir_x(1, beam_angle - _ang); // same direction in the box's own frame, for the wall cutoff
var _ly = lengthdir_y(1, beam_angle - _ang);
var _hw = (_in.x2 - _in.x1) / 2;
var _hh = (_in.y2 - _in.y1) / 2;
var _len = min((abs(_lx) > 0.001) ? _hw / abs(_lx) : 100000,
               (abs(_ly) > 0.001) ? _hh / abs(_ly) : 100000);

draw_set_color(telegraph_color);
draw_line_width(cx - _dx * _len, cy - _dy * _len, cx + _dx * _len, cy + _dy * _len, telegraph_width);
draw_set_color(c_white);