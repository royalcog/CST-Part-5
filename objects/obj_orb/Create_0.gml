scaleup = false;
scaledown = false;
is_fading = false;
depth = -150;

current_hue = irandom(255); // Pick a random color for it to eventually become
current_sat = 0;            // 0 saturation = pure white
sat_speed = 1.5;            // How fast it fades out of white into color
hue_speed = 0.2;            // How fast it cycles through hues afterward
is_colored = false;

// Apply initial white blend
image_blend = make_color_hsv(current_hue, current_sat, 255);