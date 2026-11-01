// (stays put on the screen when the camera pans, if follow_cam's on: see Create)
var _ucx = instance_exists(obj_camera_controller) ? obj_camera_controller.cam_x : camera_get_view_x(view_camera[0]);
var _ucd = _ucx - ui_cam_x;
ui_cam_x = _ucx;
if (follow_cam && _ucd != 0) { x += _ucd; target_x += _ucd; onscreen_x += _ucd; offscreen_x += _ucd; }

x = lerp(x, target_x, 0.2);
hide_y = lerp(hide_y, ui_hidden ? hide_drop : 0, 0.2);
menu_lift = lerp(menu_lift, menu_lift_target, 0.25);
y = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) - 150 - menu_lift + hide_y;