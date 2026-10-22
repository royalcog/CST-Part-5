if (mode == "leave")
{
    // the reverse: off his back, faster and faster, back the way it came
    x += lengthdir_x(leave_speed, leave_dir);
    y += lengthdir_y(leave_speed, leave_dir);
    leave_speed *= leave_accel;

    var _cam = view_camera[0];
    if (x > camera_get_view_x(_cam) + camera_get_view_width(_cam) + 40) instance_destroy();
    exit;
}

if (!instance_exists(obj_king)) { instance_destroy(); exit; }

var _target_x = obj_king.x + back_offset_x;
var _target_y = obj_king.y + back_offset_y;

x += (_target_x - x) * ease_speed;
y += (_target_y - y) * ease_speed;

if (point_distance(x, y, _target_x, _target_y) <= merge_dist)
{
    if (laugh)
    {
        // cape has "merged" - delete both current sprites and swap king to his laugh sprite
        obj_king.sprite_index = spr_king_laugh;
        obj_king.image_index = 0;
        obj_king.image_speed = 1;

        audio_play_sound(snd_kinglaugh, 10, false);
    }
    else if (!is_undefined(on_merge))
    {
        on_merge();
    }
    else
    {
        obj_king.sprite_index = spr_king_battle_idle;
        obj_king.image_index = 0;
        obj_king.image_speed = 1;
    }

    instance_destroy();
}