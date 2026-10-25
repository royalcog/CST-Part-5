// a gust ("W" in the map): while you're around here, the wind picks up every so often and shoves the one you're
// controlling sideways. streaks start blowing first so you can brace (walk into it, or stay away from the edge)
diff        = scr_plat_difficulty(y);
near        = 320;                           // active while you're this close (px, up/down)
calm_len    = round(lerp(220, 130, diff));   // frames between gusts
warn_len    = round(lerp(65, 40, diff));     // frames of light streaks first
gust_len    = 80;                            // frames it pushes
push        = lerp(1.1, 2.4, diff);          // px per frame at full strength (you walk at 3.5, so you can always walk against it)
streak_col  = c_white;

phase   = "calm";      // calm -> warn -> gust
t       = irandom(calm_len);
dir     = choose(-1, 1);
streaks = [];          // { x, y, len, spd, a } in screen px