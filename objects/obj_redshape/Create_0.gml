// a red shape (Deltarune's obj_redshape): a copy that can't be purified. it homes in on the SOUL, the homing
// wears off over ~4 seconds (then it flies straight), it spins, and it's 2.5x as fast as a copy.
// the light only slows it to half speed. it goes straight through the SOUL instead of vanishing. can't be grazed.
// (Deltarune's numbers at 30fps, converted to our 60)
ctrl   = noone;
damage = 110;

speed_max   = 2.8125;   // a copy's 1.125 x 2.5  [DR 5.625]
accel       = 0.0375;   // [DR 0.15]
track       = 1;        // how hard it homes; wears off...
track_decay = 0.004375; // ...by this a frame  [DR 0.00875]
spin        = 1.40625;  // deg a frame it spins  [DR 2.8125]
wait_time   = 120;      // frames it sits before it goes  [DR alarm[0] = 60]
hit_radius  = 12;       // DR's radius 22, scaled like the copies' hitboxes
art_scale   = 1;      // same size relative to the copies as in Deltarune
keep_homing = true;   // DR: reds inherit the copies' stroke-turning, so they never stop homing (false = they fly straight once `track` runs out)

// --- state ---
dir   = instance_exists(obj_soul) ? point_direction(x, y, obj_soul.x, obj_soul.y) : 270;   // aimed at the SOUL as it spawns
angle = dir;
spd   = 0;
t     = 0;
trail = [];
fading = false;
image_alpha = 0;