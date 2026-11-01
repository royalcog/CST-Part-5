// one of Susie's rescue heals (obj_battle_menu's rescue_update): flies out of her hand ahead of her, then curves in,
// tighter and tighter, until it reaches whoever it's for, and heals them to full
// --- set right after making it ---
box    = noone;   // their party box (obj_battle_ui_box)
target = noone;   // their body
dir    = 0;       // the way it sets off

// --- tuning ---
spd       = 4;     // px per frame to start...
spd_max   = 8;     // ...speeding up to this
spd_acc   = 0.12;
turn      = 1;     // deg per frame it can turn to start...
turn_acc  = 0.35;  // ...more and more each frame (so it always gets there)
radius    = 6;     // how big it's drawn
col       = make_color_rgb(0, 255, 0);
trail_len = 10;

t     = 0;
trail = [];