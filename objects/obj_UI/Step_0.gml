x = lerp(x, target_x, 0.2);
hide_y = lerp(hide_y, ui_hidden ? hide_drop : 0, 0.2);
menu_lift = lerp(menu_lift, menu_lift_target, 0.25);
y = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) - 150 - menu_lift + hide_y;