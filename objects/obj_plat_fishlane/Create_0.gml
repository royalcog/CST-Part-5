// one Titan fish ("F" in the map, just above a runway) swimming round and round the tower forever at this height.
// it never stops: watch for it coming round the side, and jump it
diff     = scr_plat_difficulty(y);
floor_y  = y + 40;                 // set by scr_plat_build_tower: the top of the ledge below
fish_spd = lerp(6, 7.5, diff);     // still clearable in one jump at either end
scale    = 1.4;
dir      = choose(-1, 1);
fish     = noone;