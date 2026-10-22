function scr_pick_target_soul_or_random(_chance_soul = 0.5)
{
    if (instance_exists(obj_soul) && random(1) < _chance_soul)
    {
        return { x: obj_soul.x, y: obj_soul.y };
    }
    else if (instance_exists(obj_battlebox))
    {
        var _bb = obj_battlebox;
        return {
            x: irandom_range(_bb.x + 30, _bb.x + _bb.sprite_width - 30),
            y: irandom_range(_bb.y + 15, _bb.y + _bb.sprite_height - 15)
        };
    }
    else if (instance_exists(obj_soul))
    {
        return { x: obj_soul.x, y: obj_soul.y };
    }
    else
    {
        return noone; // signal "nothing to target" — let the caller decide
    }
}