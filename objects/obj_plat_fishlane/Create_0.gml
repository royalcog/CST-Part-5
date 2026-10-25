// Titan fish swimming along a runway ("F" in the map, just above it). they only come while you're near.
floor_y  = y + 40;    // set by scr_plat_build_tower: the top of the ledge below
every    = 200;       // frames between fish
first    = 60;        // frames after you arrive before the first one
fish_spd = 6.5;
scale    = 1.4;
warn     = 54;        // frames the "!" shows first
near     = 300;       // only while the middle of the screen is this close (px, up/down)
t        = every - first;