// burst of light blue when the soul changes
if (flash_t > 0)
{
    var _k = 1 - flash_t / change_flash_frames;
    var _col = make_color_rgb(66, 252, 255);
    gpu_set_blendmode(bm_add);
    draw_set_color(_col);
    draw_set_alpha((1 - _k) * 0.8);
    draw_circle(flash_x, flash_y, change_flash_radius * _k, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}