if (instance_exists(obj_friend)) { obj_friend.visible = true; }

if (instance_exists(left_hand))  instance_destroy(left_hand);
if (instance_exists(right_hand)) instance_destroy(right_hand);
if (instance_exists(chase_hand)) instance_destroy(chase_hand);

with (obj_rps_squeeze_hand)  instance_destroy();
with (obj_paper_shockwave)   instance_destroy();
with (obj_friend_hand_punch) instance_destroy();

if (instance_exists(obj_battlebox))
{
    obj_battlebox.target_scale_x = 1;
    obj_battlebox.target_scale_y = 1;
}