if (impact_flash_state >= 1 && impact_flash_state <= 6)
{
    draw_set_alpha(impact_flash_darken_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);

    var _gui_scale_x = display_get_gui_width() / camera_get_view_width(view_camera[0]);
    var _gui_scale_y = display_get_gui_height() / camera_get_view_height(view_camera[0]);

    // silhouette - matches live sprite size/position exactly
    if (impact_flash_state <= 3)
    {
        var _gui_x = (impact_flash_target.x - camera_get_view_x(view_camera[0])) * _gui_scale_x;
        var _gui_y = (impact_flash_target.y - camera_get_view_y(view_camera[0])) * _gui_scale_y;

        draw_sprite_ext(impact_flash_silhouette_spr, impact_flash_target.image_index, _gui_x, _gui_y,
            impact_flash_target.image_xscale * _gui_scale_x,
            impact_flash_target.image_yscale * _gui_scale_y,
            impact_flash_target.image_angle, c_white, 1);
    }

    // rushing oval "cat blur"
    if (impact_flash_state == 2 || impact_flash_state == 3)
    {
        var _circle_gui_x = (impact_flash_circle_x - camera_get_view_x(view_camera[0])) * _gui_scale_x;
        var _circle_gui_y = (impact_flash_circle_y - camera_get_view_y(view_camera[0])) * _gui_scale_y;

        draw_set_alpha(impact_flash_circle_alpha);
        draw_set_color(c_white);
        var _segments = 8;
        draw_primitive_begin(pr_trianglefan);
		draw_vertex(_circle_gui_x, _circle_gui_y);
		for (var i = 0; i <= _segments; i++)
		{
		    var _theta = i * (360 / _segments);
		    var _jitter = random_range(-4, 4); // <-- roughness amount, tweak as needed
		    var _lx = lengthdir_x((impact_flash_circle_len / 2) + _jitter, _theta);
		    var _ly = lengthdir_y((impact_flash_circle_wid / 2) + _jitter, _theta);
		    var _rx = _lx * dcos(impact_flash_circle_angle) - _ly * dsin(impact_flash_circle_angle);
		    var _ry = _lx * dsin(impact_flash_circle_angle) + _ly * dcos(impact_flash_circle_angle);
		    draw_vertex(_circle_gui_x + _rx, _circle_gui_y + _ry);
		}
		draw_primitive_end();
        draw_set_alpha(1);
    }
}