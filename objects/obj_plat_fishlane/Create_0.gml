// Titan fish swimming along a runway ("F" in the map, just above it). they only come while you're near.
diff     = scr_plat_difficulty(y);
floor_y  = y + 40;                            // set by scr_plat_build_tower: the top of the ledge below
every    = round(lerp(280, 160, diff));       // frames between fish (more often higher up)
first    = 60;                                // frames after you arrive before the first one
fish_spd = lerp(6, 7.5, diff);                // still clearable in one jump at either end
scale    = 1.4;
warn     = round(lerp(70, 45, diff));         // frames the "!" shows first
near     = 300;                               // only while the middle of the screen is this close (px, up/down)
t        = every - first;