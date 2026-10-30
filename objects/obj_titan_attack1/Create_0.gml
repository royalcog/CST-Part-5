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
spade_wait       = 30;   // frames each one sits just outside the box (where you can see it) before it comes in
spade_hit_radius = 12;   // spade centre -> SOUL centre (smaller than the art, so it's fair)
spade_offset     = 30;   // how far outside the box they stop and wait (px, to the spade's middle)
spade_approach   = 80;   // how much further out than that they first appear, gliding in from there
spade_approach_time = 20; // frames that glide in takes
spade_start      = 60;   // frames into the attack before the first one
spade_stop       = 90;   // no new ones in the last this-many frames (so none get cut off by the box closing)

spade_timer = spade_start;
next_side   = choose(-1, 1);   // they alternate: left, right, left... (-1: in from the left)