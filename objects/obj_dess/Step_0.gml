if !anim_loop && image_index >= image_number - 1
{
    image_speed = 0;
    image_index = image_number - 1;
}

scr_char_jolt_update(self);