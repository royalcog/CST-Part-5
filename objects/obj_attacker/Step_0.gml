if (attack_active)
{
    var _d = attack_data;

    if (sprite_index != _d.anim_sprite)
    {
        sprite_index = _d.anim_sprite;
        image_speed = 0;
        image_index = 0;
        anim_timer = 0;
        thrown_this_cycle = false;
    }

    anim_timer++;
    if (anim_timer >= _d.frame_time)
    {
        anim_timer = 0;
        image_index++;

        if (image_index == 1 && !thrown_this_cycle)
		{
		    audio_play_sound(snd_smallswing, 5, false, 1.25);
		    _d.spawn_func(x + _d.offset_x, y + _d.offset_y, _d.damage_amount, _d.color_top, _d.color_bottom);
		    thrown_this_cycle = true;
		    proj_thrown++;
		}

        if (image_index > 2)
        {
            image_index = 0;
            thrown_this_cycle = false;
        }
    }

    if (proj_thrown >= _d.max_count)
    {
        sprite_index = _d.idle_sprite;
        image_speed = 1;
        image_index = 0;
        attack_active = false;
        proj_thrown = 0;
    }
}