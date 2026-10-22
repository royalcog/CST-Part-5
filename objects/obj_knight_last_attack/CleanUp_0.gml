scr_soul_swap_cleanup();     // soul colour back for later rounds, Ralsei never stuck mid-spell
scr_knight_swing_restore();  // never leave him stuck mid-swing
with (obj_soul) { grid_blocked = array_create(9, false); shield_dirs = 4; shield_arc = 50; }