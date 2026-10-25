// a ring of white dots going round and round. touching one hurts (only the one you're controlling).
// the gaps between dots are wider than Susie/Ralsei are tall, so you can always slip through one, or wait inside the ring.
// made by scr_plat_build_tower ("O" = this, "Q" = bigger and backwards). x/y = its middle
count      = 6;
radius     = 140;
spd        = 1.4;     // degrees per frame (negative = the other way)
dot_r      = 7;       // how big they look...
hit_r      = 4;       // ...and how close you have to get to one to get hurt
glow       = 0.3;
damage_min = 18;
damage_max = 26;
ang        = random(360);
pulse      = 0;