if (black.a > 0)
{
    draw_set_alpha(black.a);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}