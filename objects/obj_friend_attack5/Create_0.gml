timer = 0;
attack_duration = 720; // ~12 seconds at 60fps — tune as needed

left_hand = noone;
right_hand = noone;

if (instance_exists(obj_friend)) { obj_friend.visible = false; }

left_hand  = instance_create_depth(0, 0, -380, obj_friend_hand_gun, { side: "left"  });
right_hand = instance_create_depth(0, 0, -380, obj_friend_hand_gun, { side: "right" });