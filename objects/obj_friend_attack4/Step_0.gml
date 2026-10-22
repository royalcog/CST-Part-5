timer++;

prev_angle = angle;
angle = swing_amplitude * dsin(360 * timer / swing_period);

var _direction_now = sign(angle - prev_angle);
if (_direction_now != 0 && swing_direction != 0 && _direction_now != swing_direction)
{
    color_mode = choose("blue", "orange");
}
if (_direction_now != 0) swing_direction = _direction_now;

if (instance_exists(obj_soul))
{
    var _tip_offset = scr_rotate_point(0, tail_length, angle);
    var _tip_x = pivot_x + _tip_offset.x;
    var _tip_y = pivot_y + _tip_offset.y;

    var _dist = scr_point_segment_distance(obj_soul.x, obj_soul.y, pivot_x, pivot_y, _tip_x, _tip_y);

    if (_dist <= tail_half_width + 10)
    {
        // driven by held input, not realized position delta — the old
        // position-delta check could read "not moving" even while a
        // direction key was held, whenever the wall-clamp correction in
        // obj_soul's Step canceled out that frame's movement (e.g. dodging
        // right up against the box edge), which is exactly the situation
        // players are most likely to be in while trying to move through
        // the orange tail
        var _is_moving = (obj_soul.hdir != 0) || (obj_soul.vdir != 0);
        var _should_hit = ((color_mode == "blue") && _is_moving) || ((color_mode == "orange") && !_is_moving);

        if (_should_hit)
        {
            scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
        }
    }
}

if (timer >= pendulum_duration)
{
    instance_destroy();
}