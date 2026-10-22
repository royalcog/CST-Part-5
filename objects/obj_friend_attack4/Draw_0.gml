var _color = (color_mode == "blue") ? color_blue : color_orange;

if (!surface_exists(tail_surf))
{
    tail_surf = surface_create(tail_surf_size, tail_surf_size);
}

surface_set_target(tail_surf);
draw_clear_alpha(0, 0);

draw_sprite_ext(
    sprite_index,
    image_index,
    tail_surf_size / 2,
    tail_surf_size / 2,
    tail_scale,
    tail_scale,
    angle,
    c_white,
    1
);

gpu_set_blendmode_ext(bm_dest_alpha, bm_inv_src_alpha);

draw_rectangle_color(
    0,
    0,
    tail_surf_size,
    tail_surf_size,
    _color,
    _color,
    _color,
    _color,
    false
);

gpu_set_blendmode(bm_normal);

surface_reset_target();