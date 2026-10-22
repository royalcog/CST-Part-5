if (hurt_timer > 0)
{
    hurt_timer--;
    if (hurt_timer <= 0)
    {
        sprite_index = pre_hurt_sprite;
        image_index = pre_hurt_image_index;
        image_speed = pre_hurt_image_speed;
    }
}