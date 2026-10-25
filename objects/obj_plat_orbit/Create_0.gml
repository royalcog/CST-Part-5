// a ring of white dots going round and round. touching one hurts (only the one you're controlling).
// the gaps between dots are wider than Susie/Ralsei are tall, so you can always slip through one, or wait inside the ring.
// made by scr_plat_build_tower ("O" = this, "Q" = bigger and backwards). x/y = its middle
diff       = scr_plat_difficulty(y);
count      = round(lerp(3, 5, diff));   // more dots higher up...
spd        = lerp(0.7, 1.3, diff);      // ...spinning faster (degrees per frame, negative = the other way)
hit_r      = 3;       // ...and how close you have to get to one to get hurt
dot_r      = 7;       // how big they look...
glow       = 0.3;
damage_min = 18;
damage_max = 26;
ang        = random(360);
pulse      = 0;