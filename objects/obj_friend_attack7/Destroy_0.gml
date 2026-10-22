scr_screen_flip_to(0, 1);

if (instance_exists(obj_camera_controller))
{
    obj_camera_controller.tilting = false;
    obj_camera_controller.tilt_stopping = false;
    obj_camera_controller.tilt_offset = 0;
}

if (instance_exists(obj_battlebox)) obj_battlebox.target_scale_y = 1;

if (instance_exists(obj_mewmew))
{
    obj_mewmew.sprite_index = spr_mewmew_walkup_corrupted;
}

if (instance_exists(obj_friend))
{
    obj_friend.sprite_index = friend_restore_sprite;
    obj_friend.image_index  = 0;
    obj_friend.image_speed  = friend_restore_speed;
    obj_friend.visible = true;
}