var _camx = camera_get_view_x(view_camera[0]);
var _camy = camera_get_view_y(view_camera[0]);
var _camw = camera_get_view_width(view_camera[0]);

offscreen_x = _camx + _camw + sprite_width;
onscreen_x = _camx + _camw - 60;

x = offscreen_x;
target_x = onscreen_x;

spawn_index = 0;

spawn_y = [
    _camy + 180,
    _camy + 215,
    _camy + 250,
    _camy + 285
];


alarm[0] = game_get_speed(gamespeed_fps);
