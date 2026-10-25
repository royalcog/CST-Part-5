if (!is_struct(arena)) { instance_destroy(); exit; }

// the "!" warning first, then in it comes
if (warn_t > 0) { warn_t--; exit; }

if (vert) oy += dir * spd;
else      ox += dir * spd;
if (loop) ox = scr_plat_wrap(ox);   // round and round the tower, forever
phase += wave_speed;
anim  += sprite_get_speed(spr_titanfish_head) / game_get_speed(gamespeed_fps);
if (fading) alpha -= 0.06;

// gone once the tail's off the far side of the screen (or it's faded). lane fish never go
if (!loop)
{
    var _tail = piece(segs + 1);
    var _gone;
    if (vert)
    {
        var _vy = camera_get_view_y(view_camera[0]), _vh = camera_get_view_height(view_camera[0]);
        _gone = (dir > 0) ? _tail.y > _vy + _vh + 60 : _tail.y < _vy - 60;
    }
    else _gone = _tail.ox * dir > camera_get_view_width(view_camera[0]) / 2 + 60;
    if (alpha <= 0 || _gone) { instance_destroy(); exit; }
}
else if (alpha <= 0) { instance_destroy(); exit; }

// hits the one you're controlling (the one following isn't in danger)
if (!fading)
{
    var _ctl = instance_exists(obj_plat_controller) ? instance_find(obj_plat_controller, 0) : noone;
    if (_ctl != noone)
    {
        var _l = _ctl.leader();
        for (var k = 0; k <= segs + 1; k++)
        {
            var _p  = piece(k);
            var _wx = arena.cx + _p.ox;                      // this piece, in the room
            var _rx = _l.x + scr_plat_wrap_dx(_l.x, _wx);    // ...on the leader's side of the tower
            var _cx = clamp(_rx, _l.x - _l.hw, _l.x + _l.hw);
            var _cy = clamp(_p.y, _l.y - _l.hh, _l.y);
            if (point_distance(_rx, _p.y, _cx, _cy) <= hit_r * scale)
            {
                _l.take_hit(scr_plat_wrap(_wx), irandom_range(damage_min, damage_max));
                break;
            }
        }
    }
}