// --- tuning (matches attack 1) ---
sword_scale      = 1.5;
tip_angle_offset = 0;
side_gap         = 10;
launch_speed     = 42;
trail_len        = 5;
flight_alpha     = 0.45;
fade_in_frames   = 10;
hit_radius       = 5;
damage           = 85;
hit_color_top    = c_white;
hit_color_bottom = c_white;
fire_sound       = snd_knight_cut;
shatter_sound    = snd_glassbreak;
shatter_frames   = 14;
shatter_color    = make_color_rgb(255, 0, 255);

// --- state (spawner sets x/y/dir/charge/travel_max) ---
dir        = 0;
charge     = 60;
t          = 0;
alpha      = 0;
state      = "charge";
vx = 0; vy = 0;
trail      = [];
travelled  = 0;
travel_max = 1000;
shatter_t  = 0;
shatter_x  = 0;
shatter_y  = 0;
half       = sprite_get_width(spr_roaringknight_sword) * sword_scale / 2;
needs_box  = instance_exists(obj_battlebox) && obj_battlebox.visible; // false = screen-wide (box was broken)

// a volley firing together shouldn't stack the same sound a dozen times
if (!variable_global_exists("lane_sword_snd_time")) global.lane_sword_snd_time = 0;
if (!variable_global_exists("lane_shatter_snd_time")) global.lane_shatter_snd_time = 0;