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

// --- the bar breaking (scr_tp_break) ---
broken        = false;
shards        = [];
shard_strips  = 9;        // the bar's cut into this many strips...
shard_gravity = 0.35;
break_shake   = 6;
break_sounds  = [snd_glassbreak, snd_impact];

/// it shatters: the bar, "TP" and the number all burst apart and fall off the screen
break_bar = function()
{
    if (broken) return;
    broken = true;
    var _ox  = -slide_dist * (1 - slide);
    var _left = bar_x + _ox - sprite_get_xoffset(spr_tensionbar);
    var _top  = bar_y - sprite_get_yoffset(spr_tensionbar);
    var _h    = sprite_get_height(spr_tensionbar);
    var _sh   = ceil(_h / shard_strips);
    var _fill = clamp(shown_tp / 100, 0, 1);
    for (var i = 0; i < shard_strips; i++)
    {
        var _sy = i * _sh;
        array_push(shards, { kind: "bar", sy: _sy, sh: min(_sh, _h - _sy), x: _left, y: _top + _sy, fill: _fill,
                             vx: random_range(-1, 3), vy: random_range(-5, -1), rot: 0, vr: random_range(-6, 6), a: 1 });
    }
    array_push(shards, { kind: "logo", x: logo_x + _ox, y: logo_y, vx: random_range(1, 3), vy: random_range(-6, -3), rot: 0, vr: random_range(-8, 8), a: 1 });
    for (var i = 0; i < array_length(break_sounds); i++) audio_play_sound(break_sounds[i], 1, false);
    scr_camera_shake(break_shake, 14);
}

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