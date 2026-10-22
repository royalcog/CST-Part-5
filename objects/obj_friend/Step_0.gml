if (fade_active)
{
    fade_alpha += fade_speed;
    if (fade_alpha >= 1)
    {
        fade_alpha = 1;
        fade_active = false;
        sprite_index = fade_new_sprite;
        image_index = fade_new_image;
        x = fade_x;
        y = fade_y;
        image_speed = 0; // or 1 if you want it animating afterward
    }
}

if (sprite_index = spr_friend_lookforward && fade_active = false && spawnedin = true && spawnedout = false)
{
	image_index = 1;
}

if (global.DEBUG_BARRAGE)
{
    if (keyboard_check(vk_left))  global.dbg_friend_offx -= 1;
    if (keyboard_check(vk_right)) global.dbg_friend_offx += 1;
    if (keyboard_check(vk_up))    global.dbg_friend_offy -= 1;
    if (keyboard_check(vk_down))  global.dbg_friend_offy += 1;
}