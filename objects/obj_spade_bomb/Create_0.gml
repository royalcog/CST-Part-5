// --- tuning ---
bomb_sprite    = spr_spade; // swap for a real spade-bomb sprite when you have one
bomb_scale     = 1.5;
toss_frames    = 40;   // how long the arc from King takes
arc_height     = 90;   // how high the arc goes
spin_speed     = 12;   // deg/frame while it's in the air
fuse_frames    = 70;   // time on the ground before it bursts
fuse_swell     = 0.2;  // grows by this much (20%) over the fuse
flash_slow     = 14;   // frames between flashes at the start of the fuse...
flash_fast     = 3;    // ...and right before it bursts
fuse_sound     = snd_select; // beep on each flash, -1 for none
fuse_gain      = 0.35;
burst_sound    = snd_bomb;   // -1 for none
bomb_damage     = 36;
bomb_hit_radius = 18;  // at bomb_scale; grows with the fuse swell
target_flashes   = 3;       // how many times the bullseye blinks during the toss
target_radius    = 16;      // outer ring
target_thickness = 2;       // ring thickness in px
target_color     = c_red;

ring_count      = 8;
ring_speed      = 3;
ring_damage     = 36;
ring_hit_radius = 12;

// set by obj_king_bomb_attack right after spawning
start_x = x;
start_y = y;
land_x  = x;
land_y  = y;

// --- state ---
sprite_index = bomb_sprite;
image_speed  = 0;
image_xscale = bomb_scale;
image_yscale = bomb_scale;
spin_dir = choose(-1, 1);
state = "toss";
timer = 0;
flash_timer = 0;
flash_countdown = 0;