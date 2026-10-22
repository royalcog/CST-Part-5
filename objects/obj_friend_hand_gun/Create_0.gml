if (!variable_instance_exists(id, "side")) side = "left";
if (!variable_instance_exists(id, "fade_in_duration")) fade_in_duration = 0; // >0 makes it spawn faded out, stationary, and hold fire until it's fully visible

sprite_index = spr_friend_hand_gun;
image_index = 0;
image_speed = 0;

hand_scale = 0.85;

muzzle_local_x = 238 - 120;
muzzle_local_y = 85 - 106;

move_speed = 1.6;
move_dir = 1;
move_vel = 0;
move_ease = 0.08;

recoil_angle = 0;
recoil_kick = 25;
recoil_recover_rate = 0.15;

shoot_timer = irandom_range(30, 60);
shoot_interval_min = 50;
shoot_interval_max = 100;

is_corner = (side == "top_left" || side == "top_right" || side == "bottom_left" || side == "bottom_right");

if (is_corner)
{
    var _view_x = camera_get_view_x(view_camera[0]);
    var _view_y = camera_get_view_y(view_camera[0]);
    var _view_w = camera_get_view_width(view_camera[0]);
    var _view_h = camera_get_view_height(view_camera[0]);
    var _margin = 40;

    var _left    = _view_x + _margin;
    var _right   = _view_x + _view_w - _margin;
    var _top     = _view_y + _margin;
    var _bottom  = _view_y + _view_h - _margin;
    var _center_x = _view_x + _view_w / 2;
    var _center_y = _view_y + _view_h / 2;

    switch (side)
    {
        case "top_left":
            x = _left;  y = _top;
            movement_axis = "y";
            move_dir = 1;
        break;
        case "bottom_right":
            x = _right; y = _bottom;
            movement_axis = "y";
            move_dir = -1;
        break;
        case "top_right":
            x = _right; y = _top;
            movement_axis = "x";
            move_dir = -1;
        break;
        case "bottom_left":
            x = _left;  y = _bottom;
            movement_axis = "x";
            move_dir = 1;
        break;
    }

    image_xscale = hand_scale;
    image_yscale = hand_scale;
    base_angle = point_direction(x, y, _center_x, _center_y);
}
else
{
    movement_axis = "y";
    image_xscale = (side == "left") ? hand_scale : -hand_scale;
    image_yscale = hand_scale;
    base_angle = 0;

    if (instance_exists(obj_battlebox))
    {
        var _interior = scr_get_box_interior();
        x = (side == "left") ? _interior.x1 : _interior.x2;
        y = (side == "left") ? _interior.y1 : _interior.y2;
    }

    if (side == "right") move_dir = -1;
}

image_angle = base_angle;
depth = -380;
move_vel = move_dir * move_speed;

spawn_state = (fade_in_duration > 0) ? "fading_in" : "active";
fade_timer = 0;
image_alpha = (fade_in_duration > 0) ? 0 : 1;