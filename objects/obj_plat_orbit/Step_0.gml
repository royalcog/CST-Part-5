ang   += spd;
pulse += 0.12;

var _ctl = instance_find(obj_plat_controller, 0);
if (_ctl == noone) exit;
var _l = _ctl.leader();
if (abs(_l.y - y) > radius + 200) exit;   // nowhere near

var _ox = scr_plat_wrap_dx(_l.x, x);       // this ring, on their side of the tower
for (var i = 0; i < count; i++)
{
    var _a  = ang + i * 360 / count;
    var _px = _l.x + _ox + lengthdir_x(radius, _a);
    var _py = y + lengthdir_y(radius, _a);
    var _cx = clamp(_px, _l.x - _l.hw, _l.x + _l.hw);
    var _cy = clamp(_py, _l.y - _l.hh, _l.y);
    if (point_distance(_px, _py, _cx, _cy) <= dot_r)
    {
        _l.take_hit(scr_plat_wrap(_px), irandom_range(damage_min, damage_max));
        break;
    }
}