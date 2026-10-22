panning = false;
pan_start_x = 0;
pan_target_x = 0;
pan_timer = 0;
pan_duration = 60;

// screen shake — cam_x/cam_y are the "true" logical camera position;
// shake is applied as a temporary offset on top each step so it settles
// back to the real position instead of drifting
cam_x = camera_get_view_x(view_camera[0]);
cam_y = camera_get_view_y(view_camera[0]);
shake_timer = 0;
shake_intensity = 0;

// full-screen flip — this is now a TRUE camera rotation (camera_set_view_angle),
// not a post-process image trick. Normal room content (soul, Mewmew, Friend,
// the box) rotates correctly automatically since GameMaker's camera handles
// that natively. The handful of things that manually draw themselves in GUI
// space (hand punches, RPS hands, strip flashes, the lighting cutout around
// the box) go through scr_room_to_gui, which has been made rotation-aware
// to match — see that script for details. flip_angle: 0 = normal,
// 180 = fully flipped (upside-down).
flip_angle = 0;
flip_start = 0;
flip_target = 0;
flip_timer = 0;
flip_duration = 1;
flipping = false;

// pendulum tilt — an oscillating angle offset added on top of flip_angle,
// used mid-attack (e.g. attack7's gun phase) for a rocking-camera effect.
// Independent of the flip lerp above so it can run at the same time.
tilting = false;
tilt_timer = 0;
tilt_amplitude = 0;
tilt_period = 90; // frames per full left-right-left cycle

tilt_ramping_in = false;
tilt_ramp_timer = 0;
tilt_ramp_duration = 60; // frames to ease the swing up to full amplitude

tilt_offset = 0;
tilt_stopping = false;
tilt_stop_start = 0;
tilt_stop_timer = 0;
tilt_stop_duration = 20; // frames to ease back to level once stopped