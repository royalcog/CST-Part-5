if instance_exists(obj_fade) && obj_fade.fade_alpha > 0 {
    draw_set_alpha(obj_fade.fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}
