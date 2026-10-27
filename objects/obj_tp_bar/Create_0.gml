// the TP bar down the left side of the screen (Draw GUI, so it's over the darkness/shadows like the battle UI).
// slides in from the left when shown. orange normally, blue in darkness. "MAX" at 100%.
// also draws the white graze shell around the soul (Draw, just behind it).
scr_tp_init();

// --- tuning (GUI px; the GUI is the camera's size). Deltarune's spots (from Kristal): the bar's top-left at (38, 40),
//     "TP" at (8, 70), the number at (8, 110) with "%" at (13, 135), "MAX" stepping down diagonally ---
bar_x      = 38 + sprite_get_xoffset(spr_tensionbar);    // (its sprites' origins are centred)
bar_y      = 40 + sprite_get_yoffset(spr_tensionbar);
logo_x     = 8 + sprite_get_xoffset(spr_tensionlogo);
logo_y     = 70 + sprite_get_yoffset(spr_tensionlogo);
num_x      = 8;       // the percentage's left edge...
num_y      = 110;     // ...and top
num_scale  = 2;       // fnt_determination is Deltarune's font at half size
pct_x      = 13;      // the "%" under it
pct_y      = 135;
max_spots  = [[10, 110], [14, 130], [18, 150]];   // M, A, X
slide_dist = 90;      // px off the left edge when hidden
slide_lerp = 0.2;
fill_col_dark = make_color_rgb(0, 63, 191);   // the fill in darkness (Deltarune's reduced-TP blue)
max_col    = make_color_rgb(255, 255, 0);
shell_scale = 1.8;    // the graze shell, compared to the soul
shell_fade  = 20;     // frames it takes to fade after you stop grazing

// --- state ---
shown  = true;
slide  = 0;           // 0 = hidden, 1 = in
shown_tp = 0;         // what's drawn, catching up to the real value
glow  = 0;    // a COURAGE pickup: the bar flashes white + the TP text gets a white outline, fading (Deltarune's tension glow)
stars = [];   // spare stars rising off the bar

/// a COURAGE pellet was picked up
courage_flash = function()
{
    glow = 1;
    var _left = bar_x - sprite_get_xoffset(spr_tensionbar);
    var _top  = bar_y - sprite_get_yoffset(spr_tensionbar);
    repeat (3 + irandom(2))
    {
        var _dur = (10 + irandom(5)) * 2;   // Deltarune's, in our 60fps
        array_push(stars, { x: _left + irandom(25), y: _top + irandom(160), spd: (3 + random(3)) / 2, dur: _dur, t: 0, f: 0, a: 1 });
    }
}