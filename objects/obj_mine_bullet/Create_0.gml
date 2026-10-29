// one of a mine's 5 bullets: starts slow and squashed, stretches into shape and speeds up to 4x
damage = 110;
dir    = 0;
spd0   = 1;      // set by the mine
hit_r  = 5;
t      = 0;
flip   = choose(4, -4);   // DR: it starts 0.25 wide and 4 tall (either way up), easing to normal
fading = false;
image_alpha = 1;