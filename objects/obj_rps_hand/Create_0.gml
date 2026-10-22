if (!variable_instance_exists(id, "side")) side = "left";

sprite_index = spr_friend_hand_rock;
image_xscale = 1.1;
image_yscale = 1.1;
depth = -380;

chase_target_scale = image_xscale; // scissors eases toward this once chasing begins

base_angle = (side == "left") ? 0 : 180;
image_angle = base_angle;
draw_angle = image_angle;

bouncing = false;
bounce_progress = 0;
bounce_speed = 0.08;
tilt_amount = (side == "left") ? 45 : -45;

already_hit = false;
chasing = false;