// the white flash after the X
if (white_t > 0)
{
    draw_set_color(c_white);
    draw_set_alpha(white_t / flash_frames);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}