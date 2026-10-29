// a purified copy's COURAGE pellet (Deltarune's obj_darkshape_greenblob). it drifts toward the box's middle,
// then homes in on the SOUL, pulling harder the closer it is. touch it for TP
size      = 2;      // Deltarune: 2 in the Titan Spawn fight
tp_gain   = size * 2 / 250 * 100;   // size * 2 of Deltarune's 250 = 1.6%...
if (instance_exists(obj_battle_menu) && obj_battle_menu.turn >= 4) tp_gain *= 2;   // ...doubled from turn 4
pickup_r  = 20;     // Deltarune's
friction  = 0.92;   // Deltarune's 0.85 a frame, at our 60fps
max_speed = 3;      // (guess, it's in Deltarune's Create) px a frame
acc       = 6;      // (guess) it speeds up by acc / distance a frame: much harder up close
home_delay = 20;    // (guess) frames before it starts homing
blob_col  = c_yellow;
blob_scale    = 0.5;   // the pellet
sparkle_scale = 0.5;   // its sparkle when you pick it up

// it pops out toward the middle of the box first (Deltarune aims it there)
var _c = scr_box_center();
dir = point_direction(x, y, _c.x, _c.y);
spd = 2;
t   = 0;
f   = 0;
collected   = false;
fading      = false;
image_alpha = 1;