var _camx = camera_get_view_x(view_camera[0]);
var _camy = camera_get_view_y(view_camera[0]);
var _camw = camera_get_view_width(view_camera[0]);
var _camh = camera_get_view_height(view_camera[0]);

image_xscale = 1;
image_yscale = 1;
image_speed = 0;

offscreen_x = _camx + _camw + sprite_width;
onscreen_x = _camx + _camw - 40;

x = offscreen_x;
y = _camy; // move this number up/down

target_x = onscreen_x;
