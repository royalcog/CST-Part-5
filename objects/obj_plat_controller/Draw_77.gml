// the whole climb, bent around the tower (the normal application surface drawing is off while this is on).
// wrap_amt 1 = fully bent, 0 = flat (the fight flattens it out)
if (!wrap_on) exit;
var _pos = application_get_position();
var _vw  = camera_get_view_width(view_camera[0]);

draw_set_colour(c_black);
draw_rectangle(0, 0, window_get_width(), window_get_height(), false);

shader_set(shd_tower_wrap);
shader_set_uniform_f(u_cx, 0.5);
shader_set_uniform_f(u_r, wrap_r / _vw);
shader_set_uniform_f(u_span, (room_width / 2) / _vw);
shader_set_uniform_f(u_shade, wrap_shade);
shader_set_uniform_f(u_amt, wrap_amt);
draw_surface_stretched(application_surface, _pos[0], _pos[1], _pos[2] - _pos[0], _pos[3] - _pos[1]);
shader_reset();
draw_set_colour(c_white);