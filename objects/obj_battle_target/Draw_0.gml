// the cursor's on it: a white flash pulsing over the body (the Titan does its own, in obj_titan_reveal)
if (!targeted || kind == "titan" || !instance_exists(body)) exit;
var _a = 0.35 + 0.25 * sin(current_time / 120);
gpu_set_fog(true, c_white, 0, 0);
with (body) draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, _a);
gpu_set_fog(false, c_white, 0, 0);