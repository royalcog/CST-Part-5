t++;
switch (state)
{
    case "solid":   // the one you're controlling standing on it: it starts to go
    {
        var _ctl = instance_find(obj_plat_controller, 0);
        if (_ctl != noone)
        {
            var _l = _ctl.leader();
            if (_l.grounded && _l.y == top && abs(scr_plat_wrap_dx(cx, _l.x)) <= half + _l.hw) { state = "shake"; t = 0; }
        }
    }
    break;

    case "shake":
        if (t >= shake_len)
        {
            state = "fall";
            t = 0;
            solid = false;
            if (crack_sound != noone) audio_play_sound(crack_sound, 1, false, 0.5);
        }
    break;

    case "fall":
        if (t >= fall_len) { state = "gone"; t = 0; }
    break;

    case "gone":
        if (t >= back_after) { state = "back"; t = 0; }
    break;

    case "back":   // fades back in, solid once it's all there
        if (t >= 20) { state = "solid"; solid = true; t = 0; }
    break;
}