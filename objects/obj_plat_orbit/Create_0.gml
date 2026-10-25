// a ring of little white dots going round and round. touching one hurts (only the one you're controlling).
// made by scr_plat_build_tower ("O" = this, "Q" = bigger and backwards). x/y = its middle
count      = 6;
radius     = 64;
spd        = 2.2;     // degrees per frame (negative = the other way)
dot_r      = 6;
glow       = 0.3;
damage_min = 18;
damage_max = 26;
ang        = random(360);
pulse      = 0;