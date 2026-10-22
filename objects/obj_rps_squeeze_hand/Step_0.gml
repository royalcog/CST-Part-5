var _axis_is_x = (side == "left" || side == "right");
var _moving_positive = (side == "left" || side == "up");

switch (phase)
{
    case "in":
    {
        var _delta = move_speed * (_moving_positive ? 1 : -1);
        if (_axis_is_x) x += _delta; else y += _delta;

        var _cur = _axis_is_x ? x : y;
        var _arrived = _moving_positive ? (_cur >= target_val) : (_cur <= target_val);

        if (_arrived)
        {
            if (_axis_is_x) x = target_val; else y = target_val;
            hold_timer = hold_time;
            phase = "hold";
        }

        if (!already_hit && instance_exists(obj_soul) && scr_attack_touches_soul())
		{
		    already_hit = true;
		    scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
		}
    }
    break;

    case "hold":
        hold_timer--;

        if (!already_hit && instance_exists(obj_soul) && scr_attack_touches_soul())
		{
		    already_hit = true;
		    scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
		}

        if (hold_timer <= 0) phase = "out";
    break;

    case "out":
    {
        var _delta = move_speed * (_moving_positive ? -1 : 1);
        if (_axis_is_x) x += _delta; else y += _delta;

        var _cur = _axis_is_x ? x : y;
        var _gone = _moving_positive ? (_cur <= start_val) : (_cur >= start_val);
        if (_gone) instance_destroy();
    }
    break;
}