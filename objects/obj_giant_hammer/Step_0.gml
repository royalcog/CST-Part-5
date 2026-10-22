switch (phase)
{
    case "swing":
        timer++;
        var _t = clamp(timer / swing_duration, 0, 1);
        image_angle = lerp(start_angle, end_angle, _t);

        if (!already_hit && instance_exists(obj_soul))
        {
            var _content_length = 92 * 2; // scaled — the visible hammer length from handle to head
			var _half_len = _content_length / 2;
			var _half_h = 100; // 50 * 2 scale, unchanged

			if (!already_hit && instance_exists(obj_soul) &&
			    scr_point_in_rotated_rect(obj_soul.x, obj_soul.y, x, y, image_angle, _half_len, _half_h, _half_len, 0))
			{
			    already_hit = true;
			    scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
			}
        }

        if (_t >= 1)
        {
            audio_play_sound(snd_impact, 5, false);
            timer = 0;
            phase = "hold";
        }
    break;

    case "hold":
        timer++;
        if (timer >= hold_duration)
        {
            phase = "retract";
        }
    break;

    case "retract":
        image_alpha -= 0.1;
        if (image_alpha <= 0)
        {
            instance_destroy();
        }
    break;
}