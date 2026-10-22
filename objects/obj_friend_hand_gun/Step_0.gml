if (spawn_state == "active")
{
    var _axis_min = 0;
    var _axis_max = 0;

    if (is_corner)
    {
        var _view_x = camera_get_view_x(view_camera[0]);
        var _view_y = camera_get_view_y(view_camera[0]);
        var _view_w = camera_get_view_width(view_camera[0]);
        var _view_h = camera_get_view_height(view_camera[0]);
        var _margin = 40;

        if (movement_axis == "y")
        {
            _axis_min = _view_y + _margin;
            _axis_max = _view_y + _view_h - _margin;
        }
        else
        {
            _axis_min = _view_x + _margin;
            _axis_max = _view_x + _view_w - _margin;
        }
    }
    else if (instance_exists(obj_battlebox))
    {
        var _interior = scr_get_box_interior();
        _axis_min = _interior.y1;
        _axis_max = _interior.y2;
    }

    move_vel = lerp(move_vel, move_dir * move_speed, move_ease);

    if (movement_axis == "y")
    {
        y += move_vel;
        if (y >= _axis_max) { y = _axis_max; move_dir = -1; }
        if (y <= _axis_min) { y = _axis_min; move_dir = 1; }
    }
    else
    {
        x += move_vel;
        if (x >= _axis_max) { x = _axis_max; move_dir = -1; }
        if (x <= _axis_min) { x = _axis_min; move_dir = 1; }
    }
}

switch (spawn_state)
{
    case "fading_in":
        fade_timer++;
        image_alpha = clamp(fade_timer / fade_in_duration, 0, 1);
        if (fade_timer >= fade_in_duration)
        {
            spawn_state = "firing_first";
        }
    break;

    case "firing_first":
        image_alpha = 1;
        if (instance_exists(obj_soul))
        {
            var _muzzle_offset = scr_rotate_point(muzzle_local_x * image_xscale, muzzle_local_y * image_yscale, image_angle);
            var _muzzle_x = x + _muzzle_offset.x;
            var _muzzle_y = y + _muzzle_offset.y;

            instance_create_depth(_muzzle_x, _muzzle_y, -375, obj_friend_bullet, {
                target_x: obj_soul.x,
                target_y: obj_soul.y
            });

            recoil_angle = recoil_kick;
            image_angle = base_angle + recoil_angle;
            shoot_timer = irandom_range(shoot_interval_min, shoot_interval_max);
        }
        spawn_state = "active"; // starts patrolling + repeating fire from here on, exactly like before
    break;

    case "active":
        shoot_timer--;
        if (shoot_timer <= 0 && instance_exists(obj_soul))
        {
            var _muzzle_offset = scr_rotate_point(muzzle_local_x * image_xscale, muzzle_local_y * image_yscale, image_angle);
            var _muzzle_x = x + _muzzle_offset.x;
            var _muzzle_y = y + _muzzle_offset.y;

            instance_create_depth(_muzzle_x, _muzzle_y, -375, obj_friend_bullet, {
                target_x: obj_soul.x,
                target_y: obj_soul.y
            });

            recoil_angle = recoil_kick;
            image_angle = base_angle + recoil_angle;
            shoot_timer = irandom_range(shoot_interval_min, shoot_interval_max);
        }
        else
        {
            recoil_angle = lerp(recoil_angle, 0, recoil_recover_rate);
            image_angle = base_angle + recoil_angle;
        }
    break;
}