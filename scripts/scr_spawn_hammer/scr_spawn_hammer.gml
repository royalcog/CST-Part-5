function scr_spawn_hammer(_x, _y, _damage_amount = 0, _color_top = c_white, _color_bottom = c_white)
{
    return scr_spawn_projectile(obj_hammer, _x, _y, _damage_amount, _color_top, _color_bottom, {
        travel_time: 50,
		arc_height: 160, // was 130 — bigger arc reads as a stronger throw without needing more speed
		spin_speed: 14
    });
}

function scr_point_in_rotated_rect(_px, _py, _rx, _ry, _angle, _half_w, _half_h, _center_offset_x = 0, _center_offset_y = 0)
{
    var _rad = -degtorad(_angle);
    var _dx = _px - _rx;
    var _dy = _py - _ry;

    var _local_x = _dx * cos(_rad) - _dy * sin(_rad);
    var _local_y = _dx * sin(_rad) + _dy * cos(_rad);

    _local_x -= _center_offset_x;
    _local_y -= _center_offset_y;

    return (abs(_local_x) <= _half_w && abs(_local_y) <= _half_h);
}