var _ctl = instance_find(obj_plat_controller, 0);
if (_ctl == noone) exit;
var _l    = _ctl.leader();
var _near = abs(_l.y - y) <= near && _ctl.state == "play";

switch (phase)
{
    case "wait":
        if (!_near) { t = 0; break; }
        if (++t >= every) { phase = "aim"; pt = 0; bx = _l.x; }
    break;

    case "aim":
        pt++;
        if (pt < lock_at) bx = _l.x;   // follows you, then locks
        if (pt >= aim_len)
        {
            phase = "fire";
            pt = 0;
            if (fire_sound != noone) audio_play_sound(fire_sound, 1, false, 0.6);
        }
    break;

    case "fire":
        pt++;
        if (abs(scr_plat_wrap_dx(bx, _l.x)) <= hit_w / 2 + _l.hw)
            _l.take_hit(bx, irandom_range(damage_min, damage_max));
        if (pt >= fire_len) { phase = "fade"; pt = 0; }
    break;

    case "fade":
        if (++pt >= fade_len) { phase = "wait"; t = 0; }
    break;
}