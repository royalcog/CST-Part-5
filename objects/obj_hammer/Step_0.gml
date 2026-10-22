if (!falling)
{
    prev_y = y;
    timer++;
    var _t = clamp(timer / travel_time, 0, 1);

    x = lerp(start_x, target_x, _t);

    var _target_y = lerp(start_y, target_y, _t) - (sin(_t * pi) * arc_height);
    var _max_arc_speed = 7; // caps how fast it can move vertically per frame — tune 3-6 to taste
    var _dy = clamp(_target_y - y, -_max_arc_speed, _max_arc_speed);
    y += _dy;

    image_angle += spin_speed;

    var _hw = sprite_width * image_xscale * 0.5;
	var _hh = sprite_height * image_yscale * 0.5;

	if (instance_exists(obj_soul) && scr_point_in_rotated_rect(obj_soul.x, obj_soul.y, x, y, image_angle, _hw, _hh))
	{
	    scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
	    instance_destroy();
	    exit;
	}

    if (_t >= 1)
    {
        falling = true;
        fall_vel = 1;
    }
}
else
{
    fall_vel += 0.12;           // slower acceleration (was 0.25)
	fall_vel = min(fall_vel, 5); // lower hard cap (was 9)
    y += fall_vel;
    image_angle += spin_speed;

    var _bottom = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]);
    if (y > _bottom + 100)
    {
        instance_destroy();
    }
}