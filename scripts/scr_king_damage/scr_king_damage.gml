function scr_king_damage(_amount, _color_top = c_white, _color_bottom = c_white)
{
    if (!instance_exists(obj_king)) return noone;

    obj_king.king_hp = max(obj_king.king_hp - _amount, 0);
    audio_play_sound(snd_damagetaken, 1, false);

    with (obj_king)
    {
        if (hurt_timer <= 0) // don't restomp the stashed sprite mid-flash on rapid-fire hits
        {
            pre_hurt_sprite = sprite_index;
            pre_hurt_image_index = image_index;
            pre_hurt_image_speed = image_speed;
        }
        sprite_index = spr_king_hurt;
        image_index = 0;
        image_speed = 0;
        hurt_timer = hurt_duration;
    }

    return scr_trigger_damage_popup(obj_king, _amount, _color_top, _color_bottom, 60, 40); // further down/right on King's sprite — tune to taste
}