if (travel_sound != noone)
{
    if (travel_sound_timer <= 0)
    {
        audio_play_sound(travel_sound, 5, false);
        travel_sound_timer = travel_sound_gap;

        if (beep_flash_sprite != noone)
        {
            sprite_index = beep_flash_sprite;
            beep_flash_timer = beep_flash_duration;
        }
    }
    else
    {
        travel_sound_timer--;
    }
}

if (beep_flash_timer > 0)
{
    beep_flash_timer--;
    if (beep_flash_timer <= 0 && normal_sprite != -1)
    {
        sprite_index = normal_sprite;
    }
}

if (mode == "directional")
{
    x += dir_x * move_speed;
    y += dir_y * move_speed;
    image_angle = animate ? (image_angle + spin_speed) : point_direction(0, 0, dir_x, dir_y);
}
else if (mode == "arc")
{
    timer++;
    var _t = clamp(timer / travel_time, 0, 1);
    x = lerp(start_x, target_x, _t);
    y = lerp(start_y, target_y, _t) - (sin(_t * pi) * arc_height);
    image_angle = animate ? (image_angle + spin_speed) : point_direction(start_x, start_y, target_x, target_y);
}
else if (mode == "straight")
{
    timer++;
    var _t = clamp(timer / travel_time, 0, 1);
    x = lerp(start_x, target_x, _t);
    y = lerp(start_y, target_y, _t);
    if (animate)
    {
        image_angle += spin_speed;
    }
}
if ((mode == "arc" || mode == "straight") && !depth_switched && _t >= depth_switch_frac)
{
    depth = front_depth;
    depth_switched = true;
}

if (instance_exists(target_inst))
{
    var _hp = scr_get_hit_point(target_inst);
    if (point_distance(x, y, _hp.x, _hp.y) <= hit_radius)
    {
        audio_play_sound(snd_hurt, 5, false);
        if (impact_sound != noone) audio_play_sound(impact_sound, 5, false);
        scr_trigger_damage_popup(target_inst, damage_amount, color_top, color_bottom);
        if (after_obj != noone)
        {
            var _fx_x = (after_at == "source") ? start_x : _hp.x;
            var _fx_y = (after_at == "source") ? start_y : _hp.y;
            var _fx = instance_create_depth(_fx_x, _fx_y, -1100, after_obj);
            if (after_sprite != -1) _fx.sprite_index = after_sprite;
        }
        instance_destroy();
        exit;
    }
}
else
{
    instance_destroy();
    exit;
}

var _cam = view_camera[0];
if (x < camera_get_view_x(_cam) - 400 || x > camera_get_view_x(_cam) + camera_get_view_width(_cam) + 400
 || y < camera_get_view_y(_cam) - 400 || y > camera_get_view_y(_cam) + camera_get_view_height(_cam) + 400)
{
    instance_destroy();
}