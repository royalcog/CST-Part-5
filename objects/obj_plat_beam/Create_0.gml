// the Titan's beam ("B" in the map): while you're around here, a thin line locks onto where you're standing,
// then a beam of light comes straight down there. the line stops following you partway, so step aside and it misses.
diff       = scr_plat_difficulty(y);
near       = 320;                           // active while you're this close (px, up/down)
every      = round(lerp(200, 110, diff));   // frames between beams
aim_len    = round(lerp(65, 42, diff));     // frames the thin line shows...
lock_at    = aim_len - 22;                  // ...following you until this many in, then it stays put
fire_len   = 26;                            // frames the beam's on
fade_len   = 14;
width      = 36;                            // px wide as drawn...
hit_w      = 22;                            // ...and the part in the middle that hurts
damage_min = 22;
damage_max = 30;
fire_sound = snd_impact;

phase = "wait";       // wait -> aim -> fire -> fade
t     = irandom(every);
pt    = 0;
bx    = x;