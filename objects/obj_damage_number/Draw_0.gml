draw_set_font(fnt_greaterdetermination);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text_transformed_color(x + x_offset, y + y_offset, string(damage_amount), scale, scale, 0,
    color_top, color_top, color_bottom, color_bottom, alpha);

draw_set_halign(fa_left);
draw_set_valign(fa_top);