if (instance_exists(obj_friend)) { obj_friend.visible = true; }

if (instance_exists(hand_left))  instance_destroy(hand_left);
if (instance_exists(hand_right)) instance_destroy(hand_right);
if (instance_exists(rock_inst))  instance_destroy(rock_inst);

with (obj_friend_hand_gun) instance_destroy();
with (obj_friend_bullet)   instance_destroy();
with (obj_friend_shrapnel) instance_destroy();

if (instance_exists(obj_battlebox)) obj_battlebox.visible = true;

for (var i = 0; i < array_length(saved_light_states); i++)
{
    var _entry = saved_light_states[i];
    if (instance_exists(_entry.inst)) _entry.inst.light_on = _entry.was_on;
}

if (dark_active && instance_exists(obj_lighting))
{
    obj_lighting.darkness_target_left  = prev_darkness_left;
    obj_lighting.darkness_target_right = prev_darkness_right;
}