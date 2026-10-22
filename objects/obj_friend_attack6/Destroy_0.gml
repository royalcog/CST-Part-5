// safety net in case this attack instance is ever destroyed mid-sequence —
// make sure the screen isn't left flipped, the box isn't left shrunk,
// Pink isn't stuck scared-backwards, and Friend is visible again
scr_screen_flip_to(0, 1);

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