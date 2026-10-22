phase = "hands_in";
timer = 0;

hand_left = noone;
hand_right = noone;
yarn = noone;

hand_fade_speed = 0.04;      // ~25 steps to fully fade in/out

ramp_duration = 90;          // steps to spin up / spin down (1.5s @ 60fps)
spin_duration = 360;         // steps held at full speed — the "x seconds" (6s @ 60fps, tune as needed)

max_angular_speed = 3;       // degrees/step at full spin speed
max_hand_image_speed = 0.8;  // hand grip-animation speed at full spin speed

angular_speed = 0;
settle_target = 0;

if (instance_exists(obj_friend)) { obj_friend.visible = false; }

hand_left  = instance_create_depth(0, 0, -380, obj_rotate_hand, { side: "left"  });
hand_right = instance_create_depth(0, 0, -380, obj_rotate_hand, { side: "right" });