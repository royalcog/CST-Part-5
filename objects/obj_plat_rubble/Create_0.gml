// falling rubble ("R" in the map): while you're around here, bits of the tower crack off above and fall.
// a "!" flickers at the top of the screen where each one's about to come down
diff       = scr_plat_difficulty(y);
near       = 320;                           // active while you're this close (px, up/down)
every      = round(lerp(120, 55, diff));    // frames between rocks
warn       = round(lerp(48, 30, diff));     // frames the "!" shows first
grav       = 0.3;
max_fall   = lerp(7, 10, diff);
scale      = 0.6;
hit_r      = 16;
spread     = 220;                           // px either side of you they come down
damage_min = 15;
damage_max = 24;
fall_sound = snd_petrify_gravel;
t     = 0;
rocks = [];           // { x, y, vy, img, rot, vr, warn }