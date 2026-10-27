// a purified copy's pellet (COURAGE). drifts toward the box's middle; touch it for TP
tp_gain  = (instance_exists(obj_battle_menu) && obj_battle_menu.turn >= 4) ? 3.2 : 1.6;
pickup_r = 14;

blob_sprite = asset_get_index("spr_darkshape_transform");
pickup_snd  = snd_power;

var _c = scr_box_center();
hx = _c.x + random_range(-40, 40);
hy = _c.y + random_range(-40, 40);
t = 0;
fading = false;
image_alpha = 1;