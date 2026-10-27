if (use_party_boxes)
{
    // full-width panel behind the boxes. Every column of the panel art is identical,
    // so one column stretched across the screen = the panel's ends cloned out to both edges.
    // offset by how far the UI still has to slide, so it slides in with the box as one piece.
    if (panel_full_width)
    {
        var _pvy = camera_get_view_y(view_camera[0]);
        var _psx = display_get_gui_width()  / camera_get_view_width(view_camera[0]);
        var _psy = display_get_gui_height() / camera_get_view_height(view_camera[0]);
        var _slide = (x - onscreen_x) * _psx; // 0 once settled
        draw_sprite_part_ext(sprite_index, 0, 0, 0, 1, sprite_get_height(sprite_index),
            _slide, (y - _pvy) * _psy, display_get_gui_width(), image_yscale * _psy, c_white, 1);
    }
    if (instance_exists(active_box))
    {
        var _correction = boxes_x_correction;
        with (active_box)
        {
            var _vx = camera_get_view_x(view_camera[0]);
            var _vy = camera_get_view_y(view_camera[0]);
            var _scale_x = display_get_gui_width()  / camera_get_view_width(view_camera[0]);
            var _scale_y = display_get_gui_height() / camera_get_view_height(view_camera[0]);
            var _sx = (obj_UI.x + box_offset_x + _correction - _vx) * _scale_x;
            var _sy = (obj_UI.y + box_offset_y - active_raise_offset + obj_UI.boxes_y_correction - _vy) * _scale_y;

            var _bg_frame = selected_attack ? attack_frame : sprite_frame;
			var _frame = (hurt_timer > 0) ? hurt_frame : _bg_frame;
            var _w = sprite_get_width(_frame);
            var _h = sprite_get_height(_frame);
            var _button_h = _h - divider_y;

            var _ry = _sy + divider_y * _scale_y * frame_scale;
            draw_sprite_part_ext(_frame, 0, 0, divider_y, _w, _button_h,
                _sx, _ry, _scale_x * frame_scale, _scale_y * frame_scale, c_white, 1);

            // Deltarune's "selection matrix": on this person's turn, lines in their colour slide inward from both
            // sides of the button row and fade. drawn on its black, then the row's redrawn over them with black
            // keyed out, so they pass behind the buttons
            var _bw = _w * _scale_x * frame_scale;
            var _bh = _button_h * _scale_y * frame_scale;
            var _k  = _bw / 213;   // Deltarune's box is 213 wide
            draw_set_colour(bar_fill_color);
            for (var i = 0; i < 12; i++)
            {
                var _a = sin((sel_siner + i * 10 * pi) / 60);
                if (cos((sel_siner + i * 10 * pi) / 60) >= 0 || _a <= 0) continue;
                var _lx = _sx + (31 - _a * 30) * _k;    // 1 at the edge -> 31 as it fades
                var _rx = _sx + (181 + _a * 30) * _k;   // 211 -> 181 on the right
                draw_set_alpha(_a);
                draw_rectangle(_lx - 1, _ry, _lx, _ry + _bh, false);
                draw_rectangle(_rx - 1, _ry, _rx, _ry + _bh, false);
            }
            draw_set_alpha(1);
            draw_set_colour(c_white);
            shader_set(shd_black_key);
            shader_set_uniform_f(shader_get_uniform(shd_black_key, "u_threshold"), 0.05);
            draw_sprite_part_ext(_frame, 0, 0, divider_y, _w, _button_h,
                _sx, _ry, _scale_x * frame_scale, _scale_y * frame_scale, c_white, 1);
            shader_reset();
        }
    }
    exit;
}

var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _view_w = camera_get_view_width(view_camera[0]);
var _view_h = camera_get_view_height(view_camera[0]);
var _scale_x = _gui_w / _view_w;
var _scale_y = _gui_h / _view_h;

var _sx = (x - _vx) * _scale_x;
var _sy = (y - _vy) * _scale_y;
draw_sprite_ext(sprite_index, image_index, _sx, _sy, image_xscale * _scale_x, image_yscale * _scale_y, image_angle, c_white, 1);