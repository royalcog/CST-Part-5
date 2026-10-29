// a red shape (Deltarune's obj_redshape): fires straight at the SOUL. the light can't purify it: dodge it
ctrl   = noone;
damage = 110;

// --- tuning (guesses until we've seen Deltarune's) ---
appear_time = 24;    // fades in, aiming at the SOUL, before it fires (it locks on as it goes)
max_speed   = 2.5;   // px a frame
accel       = 0.08;
hit_radius  = 6;
art_scale   = 1;     // same size as the copies

// --- state ---
dir = instance_exists(obj_soul) ? point_direction(x, y, obj_soul.x, obj_soul.y) : 270;
spd = 0;
t   = 0;
fading = false;
image_alpha = 0;