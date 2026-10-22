if (instance_exists(obj_friend)) { obj_friend.visible = true; }

if (instance_exists(hand_left))  instance_destroy(hand_left);
if (instance_exists(hand_right)) instance_destroy(hand_right);
if (instance_exists(yarn))       instance_destroy(yarn);

with (obj_rotate_hand) instance_destroy();
with (obj_yarn)         instance_destroy();

if (instance_exists(obj_battlebox))
{
    obj_battlebox.box_angle = 0;
    obj_battlebox.target_scale_x = 1;
    obj_battlebox.target_scale_y = 1;
}