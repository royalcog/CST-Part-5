event_inherited();
// remix of attack 1 (the 6-person battle): Titan Spawn attack 1 at full strength (a copy every 24 frames at full
// size, every 5th a red shape), and instead of King's spades, the Titan's own lasers across the box where the SOUL
// is (a row, a column, or both at once), each flashing a warning first
attack_duration = 840;
spawn_gap   = 24;
spawn_scale = 1;
red_every   = 5;
spawn_rate  = 1.3;
titan_beams_init();
beam_start  = 100;   // frames in before the first laser...
beam_gap    = 95;    // ...then one every this many frames
beam_cross  = 0.3;   // how often it's a row AND a column at once
beam_stop   = 80;    // none still firing this close to the end