sprite_index = spr_giant_hammer;
image_xscale = 2.5;
image_yscale = 2.5;

angle = 200;         // wound-up start position (tilted to the side)
target_angle = 270;  // straight down — bottom of the swing
angular_vel = 0.5;    // small initial nudge
angular_accel = 0.6;  // how fast it gathers speed — tune to taste
image_angle = angle;

phase = "swing";
hold_timer = 0;
hold_duration = 15;
already_hit = false;
hit_half_len = 92;  // scaled reach — matches your existing hammer hitbox sizing
hit_half_w = 100;
safe_quadrant = "tl";