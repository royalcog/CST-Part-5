// "!" at the top of the screen where each one's about to fall
draw_set_font(fnt_determination);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_colour(c_white);
var _vx = camera_get_view_x(view_camera[0]);
for (var i = 0; i < array_length(rocks); i++)
{
    var _r = rocks[i];
    if (_r.warn <= 0 || (_r.warn div 4) mod 2 == 1) continue;
    draw_text_transformed(scr_plat_draw_x(_r.x) - _vx, 6, "!", 2, 2, 0);
}
draw_set_halign(fa_left);