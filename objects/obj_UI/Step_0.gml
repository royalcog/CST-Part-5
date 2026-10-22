x = lerp(x, target_x, 0.2);
hide_y = lerp(hide_y, ui_hidden ? hide_drop : 0, 0.2);
y = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) - 150 + hide_y;