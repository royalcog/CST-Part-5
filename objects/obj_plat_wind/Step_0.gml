var _ctl = instance_find(obj_plat_controller, 0);
if (_ctl == noone) exit;
var _l    = _ctl.leader();
var _near = abs(_l.y - y) <= near && _ctl.state == "play" && !_ctl.battle_on;
var _vw   = camera_get_view_width(view_camera[0]);
var _vh   = camera_get_view_height(view_camera[0]);

t++;
switch (phase)
{
    case "calm":
        if (!_near) { t = 0; break; }
        if (t >= calm_len) { phase = "warn"; t = 0; dir = choose(-1, 1); }
    break;

    case "warn":
        if (random(1) < 0.25) array_push(streaks, { x: (dir > 0) ? -60 : _vw + 60, y: random(_vh), len: random_range(20, 40), spd: random_range(8, 11), a: 0.3 });
        if (t >= warn_len) { phase = "gust"; t = 0; }
    break;

    case "gust":
    {
        if (random(1) < 0.8) array_push(streaks, { x: (dir > 0) ? -80 : _vw + 80, y: random(_vh), len: random_range(40, 90), spd: random_range(14, 20), a: 0.55 });
        // ramps up and down so it doesn't jerk you
        var _k = min(1, t / 12, (gust_len - t) / 12);
        if (_near) _l.ext_vx += dir * push * max(0, _k);
        if (t >= gust_len) { phase = "calm"; t = 0; }
    }
    break;
}

for (var i = array_length(streaks) - 1; i >= 0; i--)
{
    var _s = streaks[i];
    _s.x += dir * _s.spd;
    if (_s.x < -120 || _s.x > _vw + 120) array_delete(streaks, i, 1);
}