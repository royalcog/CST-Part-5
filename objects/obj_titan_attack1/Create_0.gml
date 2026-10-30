event_inherited();
// the Titan's attack 1: Titan Spawn attack 1 (the copies homing in on the SOUL, purified by its light), with King's
// spades flying straight through the box from the left and right at the same time (his Chapter 1 attack).
// made by scr_start_titan_attack1 (scr_titan_battle). everything else (sounds, the light, ending) is attack 1's

// --- tuning: the spades ---
spade_gap_min    = 50;   // frames between spades (a random gap in here)
spade_gap_max    = 70;
spade_speed      = 4;    // px per frame across the box
spade_damage     = 50;
spade_scale      = 1.5;  // (bigger than King's own, so it reads against the copies)
warn_time        = 36;   // frames its lane flashes before it comes in
warn_col         = c_red;
warn_width       = 2;    // px
spade_hit_radius = 12;   // spade centre -> SOUL centre (smaller than the art, so it's fair)
spade_offset     = 20;   // how far outside the box they start (hidden until they're in)
spade_start      = 60;   // frames into the attack before the first one
spade_stop       = 90;   // no new ones in the last this-many frames (so none get cut off by the box closing)

spade_timer = spade_start;
warnings    = [];        // lanes about to get a spade: { side, ly, t }