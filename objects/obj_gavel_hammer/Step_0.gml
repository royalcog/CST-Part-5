switch (phase)
{
    case "swing":
        angular_vel += angular_accel; // gathers speed — mimics gravity pulling it down
        angle += angular_vel;

        if (angle >= target_angle)
        {
            angle = target_angle;
        }
        image_angle = angle;

        if (!already_hit && instance_exists(obj_soul) &&
            scr_point_in_rotated_rect(obj_soul.x, obj_soul.y, x, y, image_angle, hit_half_len, hit_half_w, hit_half_len, 0))
        {
            already_hit = true;
            scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
        }

        if (angle >= target_angle)
        {
            audio_play_sound(snd_impact, 5, false);
            scr_spawn_shockwave(safe_quadrant);
            hold_timer = 0;
            phase = "hold";
        }
    break;

    case "hold":
        hold_timer++;
        if (hold_timer >= hold_duration)
        {
            phase = "retract";
        }
    break;

    case "retract":
        image_alpha -= 0.08;
        if (image_alpha <= 0)
        {
            instance_destroy();
        }
    break;
}