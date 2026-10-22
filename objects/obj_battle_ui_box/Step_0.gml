if (hurt_timer > 0) hurt_timer--;
hp_display = lerp(hp_display, hp, 0.15);

if (body_hurt_timer > 0)
{
    body_hurt_timer--;

    if (instance_exists(body_inst))
    {
        var _t = body_hurt_timer / body_hurt_time; // 1 -> 0
        var _shake = ((body_hurt_timer mod 4) < 2 ? 1 : -1) * body_shake_amount * _t;
        body_inst.x = body_saved.x + round(_shake);

        if (body_hurt_timer <= 0)
        {
            with (body_inst)
            {
                sprite_index = other.body_saved.sprite;
                image_index  = other.body_saved.index;
                image_speed  = other.body_saved.spd;
                anim_loop    = other.body_saved.loop;
                x            = other.body_saved.x;
            }
        }
    }
}