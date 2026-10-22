if (fade_active)
{
    draw_sprite_ext(fade_old_sprite, fade_old_image, x, y, image_xscale, image_yscale, 0, c_white, 1 - fade_alpha);
    draw_sprite_ext(fade_new_sprite, fade_new_image, fade_x, fade_y, image_xscale, image_yscale, 0, c_white, fade_alpha);
}
else
{
    draw_self();
}

draw_self();
if (global.DEBUG_BARRAGE)
{
    draw_set_color(c_white);
    draw_text(20, 20, "friend offx: " + string(global.dbg_friend_offx) + "  offy: " + string(global.dbg_friend_offy));
}