switch (phase)
{
    case "travel":
        travel_timer++;
        var _t = clamp(travel_timer / travel_frames, 0, 1);
        x = lerp(start_x, target_x, _t);
        y = lerp(start_y, target_y, _t);

        if (_t >= 1)
        {
            x = target_x;
            y = target_y;
            phase = "blink";
        }
        break;

    case "blink":
        blink_timer++;
        blink_toggle_timer--;
        if (blink_toggle_timer <= 0)
        {
            blink_visible = !blink_visible;
            blink_toggle_timer = blink_interval;
        }

        if (blink_timer >= blink_duration)
        {
            scr_friend_bullet_explode(id);
            instance_destroy();
        }
        break;
}