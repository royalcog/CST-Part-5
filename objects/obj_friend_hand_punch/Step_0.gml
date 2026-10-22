switch (side)
{
    case "left":  x += move_speed; break; // FIX: using move_speed
    case "right": x -= move_speed; break;
    case "up":    y += move_speed; break;
    case "down":  y -= move_speed; break;
}

var _current_val = (side == "left" || side == "right") ? x : y;
progress = abs(_current_val - start_val) / abs(target_val - start_val);

if (!already_hit && instance_exists(obj_soul) && scr_attack_touches_soul())
{
    already_hit = true;
    scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
}

var _past = false;
switch (side)
{
    case "left":  _past = (x >= target_val); break;
    case "right": _past = (x <= target_val); break;
    case "up":    _past = (y >= target_val); break;
    case "down":  _past = (y <= target_val); break;
}
if (_past) instance_destroy();