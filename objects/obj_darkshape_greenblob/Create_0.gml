// a purified copy's pellet (COURAGE). wobbles (frames 0-6) as it drifts toward the box's middle;
// touch it for TP and it sparkles (frames 7-9) and goes
tp_gain  = (instance_exists(obj_battle_menu) && obj_battle_menu.turn >= 4) ? 3.2 : 1.6;
pickup_r = 14;
blob_col = c_yellow;
pickup_snd = snd_power;

var _c = scr_box_center();
hx = _c.x + random_range(-40, 40);
hy = _c.y + random_range(-40, 40);
t = 0;
f = 0;
collected = false;
fading = false;
image_alpha = 1;