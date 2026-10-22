var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _thickness = 40;

draw_set_alpha(alpha);
draw_set_color(c_white);
switch (side)
{
    case "left":  draw_rectangle(0, 0, _thickness, _gui_h, false); break;
    case "right": draw_rectangle(_gui_w - _thickness, 0, _gui_w, _gui_h, false); break;
    case "up":    draw_rectangle(0, 0, _gui_w, _thickness, false); break;
    case "down":  draw_rectangle(0, _gui_h - _thickness, _gui_w, _gui_h, false); break;
}
draw_set_alpha(1);