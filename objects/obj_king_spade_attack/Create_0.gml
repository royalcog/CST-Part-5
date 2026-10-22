// --- tuning ---
attack_duration  = 540; // frames of spade-spawning (~9s) — raise/lower to change how long the attack lasts
spawn_gap_min    = 8;   // "very minor delay" between spades, randomized a little
spawn_gap_max    = 12;
spade_speed      = 4;
spade_damage     = 36;
spade_scale      = 1;
spade_hit_radius = 12;  // spade center -> soul center; smaller than the art on purpose so it feels fair
spade_spawn_offset = 20; // just far enough out that each spade starts fully hidden
start_delay      = 20;  // beat after the soul appears before the first spade

spin_speed_max   = 0.8; // deg/frame at full spin
spin_ramp_frames = 60;  // frames to reach full spin

attack_timer = 0;
timer = start_delay;
state = "spawning";

spin_dir = choose(-1, 1);
spin_speed = 0;
unspin_from = 0;
unspin_to = 0;
unspin_frames = 1;
unspin_timer = 0;