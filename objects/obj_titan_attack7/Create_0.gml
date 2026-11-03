event_inherited();
// remix of attack 2 (the 6-person battle): Titan Spawn attack 3 with its dashing fish back (quicker, and more often
// in pairs), the small copies coming faster, three fish to burn away instead of two, and twice the Titan's laser
// sweeps round the box: a line through its middle, turning (stay ahead of it)
attack_duration = 840;
spawn_gap  = 32;
fish_times = [40, 124, 420];
dash_start = 70;
dash_gap   = 56;
dash_pair  = 0.4;
titan_beams_init();
spin_at    = [220, 560];   // frames in each sweep starts (its warning)
spin_speed = 1.1;          // degrees a frame
spin_fire  = 170;          // frames each one sweeps for