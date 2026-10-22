image_speed = 0;
image_index = 0;

image_xscale = 2;
image_yscale = 2;
depth = obj_king.depth - 1; // adjust if it needs to draw behind him instead

back_offset_x = 46;
back_offset_y = 37;

ease_speed = 0.15;
merge_dist = 4;

depth = -99999; // draw on top of everything so the darken rect covers the whole scene

// --- set these right after creating it to change how it behaves ---
mode      = "arrive"; // "arrive": flies onto his back. "leave": tears off his back and flies away
laugh     = true;     // arrive: he laughs once it lands (false = straight into his battle pose)
dark      = true;     // darkens the screen and silhouettes him + the cape while it flies
on_merge  = undefined; // optional function: runs when it lands on him (instead of the laugh)
leave_speed = 1;      // leave: starting speed, speeds up every frame
leave_accel = 1.15;
leave_dir   = 15;     // leave: direction it flies (0 = right, 90 = up)

audio_play_sound(snd_boost, 10, false);