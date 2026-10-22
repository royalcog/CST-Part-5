mode = "directional"; // "directional", "arc", or "straight"

start_x = x;
start_y = y;
target_inst = noone;
target_x = x;
target_y = y;

move_speed = 8;
dir_x = 0;
dir_y = 0;

travel_time = 40;
timer = 0;
arc_height = 100;

animate = true;
spin_speed = 14;
hit_radius = 16;

damage_amount = 0;
color_top = c_white;
color_bottom = c_white;
impact_sound = noone;

after_obj = noone;
after_sprite = -1;
after_at = "target";

travel_sound = noone;
travel_sound_gap = 30;
travel_sound_timer = 0;

beep_flash_sprite = noone;   // sprite to show while "beeping" — noone = no flash
beep_flash_duration = 10;    // how many frames the flash sprite stays up
beep_flash_timer = 0;
normal_sprite = -1;          // set automatically at spawn — the sprite to revert to

behind_depth = 0;
front_depth = 0;
depth_switch_frac = 0.75; // fraction of the flight (0–1) at which it switches
depth_switched = false;