// a darkshape mine (Deltarune's obj_darkshape_mine). fades in (wobbling), homes in on the SOUL, and once it's
// within 64px it stops, flushes red, and blows up into a 5-bullet spread aimed at the SOUL. it can't be purified
ctrl   = noone;
damage = 110;

// --- Deltarune's values, converted to 60fps ---
speed_max   = 1.125;   // [DR 2.25]
accel       = 0.0375;  // [DR 0.15]
tracking    = 8;       // [DR 16] deg a frame it turns toward the SOUL (on top of the stroke-turning)
arm_range   = 64;      // px: this close to the SOUL and it arms
fuse_rate   = 0.0125;  // [DR 0.025]: ~80 frames from armed to boom
art_scale   = 0.65;    // [DR's]
hit_r       = 8;       // DR's radius 22 at its 0.65 size, scaled like the copies' hitboxes

// --- state ---
t     = 0;
dir   = 270;
spd   = 0;
fuse  = 0;      // DR calls it "light": 0-1, blows up at 1
anim  = random(4);
image_alpha = 0;
fading = false;