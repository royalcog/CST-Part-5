if (!variable_instance_exists(id, "side")) side = "left";

var _interior = scr_get_box_interior();
band_y1 = _interior.y1;
band_y2 = _interior.y2;

// covers the ENTIRE half of the box the hand is about to punch through,
// not just a sliver that grows toward it
var _mid_x = lerp(_interior.x1, _interior.x2, 0.5);
band_x1 = (side == "left") ? _interior.x1 : _mid_x;
band_x2 = (side == "left") ? _mid_x : _interior.x2;

hold_time = 30;
hold_timer = hold_time;
alpha = 0;
fade_in_speed = 0.15;
fade_out_speed = 0.05;
max_alpha = 0.6;
phase = "fading_in";