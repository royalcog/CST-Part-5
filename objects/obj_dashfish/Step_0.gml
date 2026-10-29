if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    alpha -= 0.1;
    if (alpha <= 0) instance_destroy();
    exit;
}

t++;
if (t <= warn_time) exit;   // the "!" first

hx    += dir * spd;
phase += wave_speed;
anim  += 0.15;

// hurts on touch, can be grazed (the light does nothing to it)
if (instance_exists(obj_soul))
{
    var _best = infinity, _bx = 0, _by = 0;
    for (var k = 0; k <= segs + 1; k++)
    {
        var _p = piece(k);
        var _d = point_distance(_p.x, _p.y, obj_soul.x, obj_soul.y);
        if (_d < _best) { _best = _d; _bx = _p.x; _by = _p.y; }
    }
    if (!obj_soul.invulnerable && _best <= hit_r) scr_soul_take_hit(damage, c_white, c_white);
    else scr_graze(_bx, _by, hit_r);
}

// gone once its tail's off the far side of the screen
var _vx   = camera_get_view_x(view_camera[0]), _vw = camera_get_view_width(view_camera[0]);
var _tail = piece(segs + 1);
if ((dir > 0 && _tail.x > _vx + _vw + 20) || (dir < 0 && _tail.x < _vx - 20)) instance_destroy();