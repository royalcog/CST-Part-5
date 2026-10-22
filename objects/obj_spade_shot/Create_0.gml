// generic box bullet for King attacks 4-6 — drawn (clipped to the box) by obj_box_bullet_drawer
// everything here gets overwritten by whichever attack spawns it
sprite_index = spr_spade;
image_speed  = 0;
visible      = false;

move_dir   = 0;
move_speed = 3;
accel      = 0;     // added to move_speed each frame once it's moving
max_speed  = 8;
damage     = 36;
hit_radius = 12;

// optional wind-up: sits still, turns to face the soul, blinks red, then fires
aim_frames   = 0;    // 0 = moves immediately
lock_frames  = 10;   // stops tracking the soul this many frames before firing (the dodge window)
aim_turn     = 0.25; // how fast it swings toward the soul while tracking (0-1)
blink_frames = 24;   // blinks red during the last N frames of the wind-up
fire_sound   = -1;
fire_gain    = 0.3;

fade_frames = 8;
fading_out  = false;
image_alpha = 0;
entered     = false; // only despawns for leaving the box once it's actually been inside
exit_margin = 24;
life        = 900;   // safety net