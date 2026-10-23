// the "!" at the edge it's about to come in from
if (warn_t <= 0 || (warn_t div 4) mod 2 == 1) exit;
var _gx = (dir > 0) ? 22 : display_get_gui_width() - 22;
var _gy = y0 - cam_y0;
draw_set_font(fnt_determination);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(c_red);
draw_text_transformed(_gx, _gy, "!", 3, 3, 0);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);