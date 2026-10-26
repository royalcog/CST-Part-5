// a Titan Spawn in the tower-top battle (made by obj_tower_top_scene). it drops in from above the screen to
// (home_x, home_y), easing to a stop, then bobs in place. drawn by its own sprite at 2x.
sprite_index = spr_titanspawn_idle;
image_xscale = 2;       // turned around to face the party (on the left)
image_yscale = 2;
image_speed  = 1;

// --- tuning ---
drop_time   = 40;       // frames to drop in
drop_delay  = 0;        // frames before it starts (the scene staggers them)
land_sound  = snd_titanspawn;
bob_amp     = 4;
bob_speed   = 0.06;

// --- state ---
home_x  = x;
home_y  = y;
from_y  = y;
state   = "wait";       // wait -> drop -> idle
t       = 0;
bob     = random(2 * pi);
landed  = false;