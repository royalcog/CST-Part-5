// falling rubble ("R" in the map): while you're around here, bits of the tower crack off above and fall.
// a "!" flickers at the top of the screen where each one's about to come down
near       = 320;     // active while you're this close (px, up/down)
every      = 75;      // frames between rocks
warn       = 36;      // frames the "!" shows first
grav       = 0.3;
max_fall   = 9;
scale      = 0.6;
hit_r      = 16;
spread     = 220;     // px either side of you they come down
damage_min = 15;
damage_max = 24;
fall_sound = snd_petrify_gravel;
t     = 0;
rocks = [];           // { x, y, vy, img, rot, vr, warn }