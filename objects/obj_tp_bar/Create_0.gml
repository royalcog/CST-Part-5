// the TP bar down the left side of the screen (Draw GUI, so it's over the darkness/shadows like the battle UI).
// slides in from the left when shown. orange normally, blue in darkness. "MAX" at 100%.
// also draws the white graze shell around the soul (Draw, just behind it).
scr_tp_init();

// --- tuning (GUI px; the GUI is the camera's size) ---
bar_x      = 38;      // the bar's centre (its sprites have a centred origin)
bar_y      = 138;     // ...
logo_x     = 4;       // the "TP" logo's top-left
logo_y     = 44;
num_x      = 14;      // the percentage, centred under the logo
num_y      = 96;
slide_dist = 90;      // px off the left edge when hidden
slide_lerp = 0.2;
fill_col_dark = make_color_rgb(70, 140, 255);   // the fill in darkness (Deltarune's blue bar)
max_col    = make_color_rgb(255, 255, 0);
shell_scale = 1.8;    // the graze shell, compared to the soul
shell_fade  = 20;     // frames it takes to fade after you stop grazing

// --- state ---
shown  = true;
slide  = 0;           // 0 = hidden, 1 = in
shown_tp = 0;         // what's drawn, catching up to the real value