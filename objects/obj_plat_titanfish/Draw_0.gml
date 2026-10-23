if (!is_struct(arena)) { instance_destroy(); exit; }

// the "!" warning first, then in it comes
if (warn_t > 0) { warn_t--; exit; }

ox    += dir * spd;
phase += wave_speed;
anim  += sprite_get_speed(spr_titanfish_head) / game_get_speed(gamespeed_fps);
if (fading) alpha -= 0.06;

// gone once the tail's off the far side (or it's faded)
var _tail = piece(segs + 1);
if (alpha <= 0 || _tail.ox * dir > camera_get_view_width(view_camera[0]) / 2 + 60) { instance_destroy(); exit; }

// hits the one you're controlling (the one following isn't in danger)
if (!fading)
{
    var _ctl = instance_exists(obj_plat_controller) ? instance_find(obj_plat_controller, 0) : noone;
    if (_ctl != noone)
    {
        var _l  = _ctl.leader();
        var _px = scr_plat_wrap_dx(arena.cx, _l.x);   // the leader, in the same "ox" terms
        for (var k = 0; k <= segs + 1; k++)
        {
            var _p  = piece(k);
            var _cx = clamp(_p.ox, _px - _l.hw, _px + _l.hw);
            var _cy = clamp(_p.y, _l.y - _l.hh, _l.y);
            if (point_distance(_p.ox, _p.y, _cx, _cy) <= hit_r * scale)
            {
                _l.take_hit(scr_plat_wrap(arena.cx + _p.ox), irandom_range(damage_min, damage_max));
                break;
            }
        }
    }
}