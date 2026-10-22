y_vel += gravity;
y += y_vel;
image_angle += spin_speed;

if (!already_hit && instance_exists(obj_soul) && point_distance(x, y, obj_soul.x, obj_soul.y) < hit_radius)
{
    already_hit = true;
    scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
}

var _interior = scr_get_box_interior();
if (!bounced && y >= _interior.y2 - 10)
{
    y = _interior.y2 - 10;
    y_vel = bounce_strength;
    y_vel = bounce_strength;
    bounced = true;
	audio_play_sound(snd_impact, 2, false, .4);
}

var _screen_bottom = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]);
if (bounced && y > _screen_bottom + 100)
{
    instance_destroy();
}