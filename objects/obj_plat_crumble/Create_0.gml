// a ledge that gives way: stand on it and it shakes, then drops out from under you. it comes back a few seconds later.
// made by scr_plat_build_tower ("C" in the map). x/y = its top-left (y = the top you stand on)
diff        = scr_plat_difficulty(y);
tiles       = 3;
shake_len   = round(lerp(70, 30, diff));    // frames it shakes before it goes (less warning higher up)
fall_len    = 36;                           // frames it takes to drop out of sight
back_after  = round(lerp(120, 200, diff));  // frames before it comes back
crack_col   = c_black;
crack_sound = snd_petrify_gravel;

state = "solid";      // solid -> shake -> fall -> gone -> back -> solid
t     = 0;
solid = true;
top   = y;
half  = 60;
cx    = x + half;

/// _n tiles wide
setup = function(_n)
{
    tiles = _n;
    half  = _n * 20;
    cx    = scr_plat_wrap(x + half);
}