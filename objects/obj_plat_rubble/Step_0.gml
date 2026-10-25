var _ctl = instance_find(obj_plat_controller, 0);
if (_ctl == noone) exit;
var _l  = _ctl.leader();
var _vy = camera_get_view_y(view_camera[0]);
var _vh = camera_get_view_height(view_camera[0]);

// a new one every so often while you're around
if (abs(_l.y - y) <= near && _ctl.state == "play" && !_ctl.battle_on)
{
    if (++t >= every)
    {
        t = 0;
        array_push(rocks, { x: scr_plat_wrap(_l.x + random_range(-spread, spread)), y: _vy - 30, vy: 0,
                            img: irandom(11), rot: random(360), vr: random_range(-6, 6), warn: warn });
    }
}

for (var i = array_length(rocks) - 1; i >= 0; i--)
{
    var _r = rocks[i];
    if (_r.warn > 0)
    {
        _r.warn--;
        if (_r.warn == 0 && fall_sound != noone) audio_play_sound(fall_sound, 1, false, 0.25, 0, random_range(1.1, 1.4));
        continue;
    }
    _r.vy   = min(max_fall, _r.vy + grav);
    _r.y   += _r.vy;
    _r.rot += _r.vr;
    if (_r.y > _vy + _vh + 60) { array_delete(rocks, i, 1); continue; }

    // hits the one you're controlling
    var _rx = _l.x + scr_plat_wrap_dx(_l.x, _r.x);
    var _cx = clamp(_rx, _l.x - _l.hw, _l.x + _l.hw);
    var _cy = clamp(_r.y, _l.y - _l.hh, _l.y);
    if (point_distance(_rx, _r.y, _cx, _cy) <= hit_r)
    {
        _l.take_hit(_r.x, irandom_range(damage_min, damage_max));
        array_delete(rocks, i, 1);
    }
}