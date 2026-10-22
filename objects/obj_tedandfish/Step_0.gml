x = lerp(x, target_x, 0.2);
y = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) - sprite_height / 2 - 195;

var _beats_per_loop = 2;

var _t = frac(global.beat / _beats_per_loop);

image_index = floor(_t * image_number);