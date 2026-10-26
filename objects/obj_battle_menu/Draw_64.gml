// ---------------------------------------------------------------- the highlighted button on the box that's choosing
if (state == "choose" && mode == "cmd" && members[chooser] != noone && instance_exists(obj_UI))
{
    var _b  = members[chooser];
    var _c  = cells[$ names[chooser]];
    var _vx = camera_get_view_x(view_camera[0]), _vy = camera_get_view_y(view_camera[0]);
    var _kx = display_get_gui_width()  / camera_get_view_width(view_camera[0]);
    var _ky = display_get_gui_height() / camera_get_view_height(view_camera[0]);
    var _bx = (obj_UI.x + _b.box_offset_x + obj_UI.boxes_x_correction - _vx) * _kx;
    var _by = (obj_UI.y + _b.box_offset_y - _b.active_raise_offset + obj_UI.boxes_y_correction - _vy) * _ky;
    var _s  = _b.frame_scale;
    var _cx = _c.xs[cmd_i[chooser]];
    shader_set(shd_button_highlight);
    draw_sprite_part_ext(_b.sprite_frame, 0, _cx, _c.y, _c.w, _c.h, _bx + _cx * _kx * _s, _by + _c.y * _ky * _s, _kx * _s, _ky * _s, c_white, 1);
    shader_reset();
}

// ---------------------------------------------------------------- the text panel
var _show = (state == "choose" || state == "exec_next" || state == "exec_run" || state == "fight" || state == "win");
if (!_show) exit;

draw_set_colour(c_black);
draw_rectangle(0, panel_y, display_get_gui_width(), display_get_gui_height(), false);
draw_set_colour(c_white);
draw_rectangle(0, panel_y, display_get_gui_width(), panel_y + 1, false);

draw_set_font(fnt_determination);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _row = function(_i) { return panel_y + 4 + _i * line_h; };
var _heart = function(_x, _y) { draw_sprite_ext(spr_soul_red, 0, _x, _y + 11, 1, 1, 0, c_white, 1); };

// FIGHT's attack boxes: one row per fighter (Deltarune's)
if (state == "fight")
{
    for (var i = 0; i < array_length(fighters); i++)
    {
        var _f = fighters[i];
        var _d = defs[_f.who];
        var _b = members[_f.who];
        var _y1 = panel_y + 4 + i * (fb_row_h + 2), _y2 = _y1 + fb_row_h;

        // their face (out of their party box's art), centred in the space left of the box
        if (_b != noone && _b.icon_rect_w > 0)
        {
            var _r  = variable_struct_exists(fb_icon_rects, names[_f.who]) ? fb_icon_rects[$ names[_f.who]]
                    : [_b.icon_rect_x, _b.icon_rect_y, _b.icon_rect_w, _b.icon_rect_h];
            var _is = fb_row_h / _r[3];
            var _ix = fb_icon_x + ((fb_box_x1 - 6 - fb_icon_x) - _r[2] * _is) / 2;
            draw_sprite_part_ext(_b.sprite_frame, 0, _r[0], _r[1], _r[2], _r[3], _ix, _y1, _is, _is, c_white, 1);
        }
        // the box in their colour, and the reticle at its left end
        var _bx2 = fb_box_x1 + fb_box_w;
        draw_set_colour(_d.color);
        draw_rectangle(fb_box_x1, _y1, _bx2, _y2, true);
        draw_rectangle(fb_box_x1 + 1, _y1 + 1, _bx2 - 1, _y2 - 1, true);
        draw_set_colour(c_white);
        draw_rectangle(fb_reticle_x - fb_cursor_w / 2 - 2, _y1 + 2, fb_reticle_x + fb_cursor_w / 2 + 2, _y2 - 2, true);

        // the cursor (only inside the box): afterimages while it moves, then it stops where it was hit and flashes out
        var _cx1 = fb_box_x1 + 2, _cx2 = _bx2 - 2;
        if (_f.phase == "move" && _f.delay <= 0)
        {
            for (var k = 0; k < array_length(_f.trail); k++)
            {
                var _tx = _f.trail[k];
                if (_tx - fb_cursor_w / 2 < _cx1 || _tx + fb_cursor_w / 2 > _cx2) continue;
                draw_set_alpha(0.5 * (1 - (k + 1) / (fb_trail + 1)));
                draw_rectangle(_tx - fb_cursor_w / 2, _y1 + 3, _tx + fb_cursor_w / 2, _y2 - 3, false);
            }
            draw_set_alpha(1);
            if (_f.x - fb_cursor_w / 2 >= _cx1 && _f.x + fb_cursor_w / 2 <= _cx2)
                draw_rectangle(_f.x - fb_cursor_w / 2, _y1 + 3, _f.x + fb_cursor_w / 2, _y2 - 3, false);
        }
        else if (_f.flash > 0 && _f.phase != "miss")
        {
            var _grow = (1 - _f.flash) * 8;
            draw_set_colour(_f.crit ? col_yellow : c_white);
            draw_set_alpha(_f.flash);
            draw_rectangle(max(_cx1, _f.x - fb_cursor_w / 2 - _grow), _y1 + 3 - _grow / 2, min(_cx2, _f.x + fb_cursor_w / 2 + _grow), _y2 - 3 + _grow / 2, false);
            draw_set_alpha(1);
        }
        // critical: little stars drifting off
        for (var k = 0; k < array_length(_f.stars); k++)
        {
            var _st = _f.stars[k];
            draw_sprite_ext(spr_sparestar_anim, 0, _st.x, (_y1 + _y2) / 2 + _st.y, 1, 1, _st.x * 4, col_yellow, _st.a);
        }
        draw_set_colour(c_white);
    }
    exit;
}

// picking from a list / a target
if (state == "choose" && mode != "cmd")
{
    switch (mode)
    {
        case "list":
        {
            var _is_item = (list == items);
            for (var i = 0; i < array_length(list); i++)
            {
                var _o = list[i];
                var _x = col_x[i mod 2], _y = _row(i div 2);
                var _can = _is_item || _o.tp <= global.tp.value;
                draw_set_colour(_can ? c_white : col_grey);
                draw_text_transformed(_x, _y, _o.name, name_scale, name_scale, 0);
                if (i == list_i) _heart(_x - 22, _y);
            }
            // the description in grey, the TP cost under it in orange (Deltarune's layout)
            var _sel = list[list_i];
            var _lines = (_sel.desc == "") ? 0 : string_count("\n", _sel.desc) + 1;
            draw_set_colour(col_grey);
            if (_lines > 0) draw_text_ext_transformed(desc_x, _row(0), _sel.desc, desc_line / desc_scale, 1000, desc_scale, desc_scale, 0);
            if (!_is_item && _sel.tp > 0)
            {
                draw_set_colour(col_orange);
                draw_text_transformed(desc_x, _row(0) + _lines * desc_line, string(_sel.tp) + "% TP", desc_scale, desc_scale, 0);
            }
        }
        break;

        case "enemy":
        {
            var _e = enemies();
            for (var i = 0; i < array_length(_e); i++)
            {
                var _en = _e[i];
                var _y = _row(i);
                draw_set_colour((_en.can_spare && _en.mercy >= 100) ? col_yellow : c_white);
                draw_text_transformed(col_x[0], _y, _en.enemy_name, name_scale, name_scale, 0);
                if (_en.can_spare && _en.is_tired()) { draw_set_colour(col_tired); draw_text_transformed(col_x[0] + 230, _y, "(Tired)", text_scale * 0.75, text_scale * 0.75, 0); }
                if (i == pick_i) _heart(col_x[0] - 22, _y);
                // HP and MERCY bars
                var _hx = 520, _mx = 680, _bw = 110, _bh = line_h - 8;
                draw_set_colour(make_color_rgb(128, 0, 0)); draw_rectangle(_hx, _y + 4, _hx + _bw, _y + 4 + _bh, false);
                draw_set_colour(make_color_rgb(0, 255, 0)); draw_rectangle(_hx, _y + 4, _hx + _bw * (_en.hp / _en.max_hp), _y + 4 + _bh, false);
                draw_set_colour(c_white);
                draw_text_transformed(_hx + 4, _y + 2, string(ceil(_en.hp / _en.max_hp * 100)) + "%", 1.5, 1.5, 0);
                if (_en.can_spare)   // no MERCY bar for things that can't be spared
                {
                    draw_set_colour(make_color_rgb(255, 80, 32)); draw_rectangle(_mx, _y + 4, _mx + _bw, _y + 4 + _bh, false);
                    draw_set_colour(col_yellow); if (_en.mercy > 0) draw_rectangle(_mx, _y + 4, _mx + _bw * (_en.mercy / 100), _y + 4 + _bh, false);
                    draw_set_colour(c_black);
                    draw_text_transformed(_mx + 4, _y + 2, string(_en.mercy) + "%", 1.5, 1.5, 0);
                }
            }
        }
        break;

        case "ally":
        {
            for (var i = 0; i < 3; i++)
            {
                var _b = members[i];
                if (_b == noone) continue;
                var _y = _row(i);
                draw_set_colour(defs[i].color);
                draw_text_transformed(col_x[0], _y, names[i], name_scale, name_scale, 0);
                draw_set_colour((_b.hp <= 0) ? c_red : c_white);
                draw_text_transformed(col_x[0] + 200, _y, "HP " + string(_b.hp) + " / " + string(_b.max_hp), name_scale, name_scale, 0);
                if (i == pick_i) _heart(col_x[0] - 22, _y);
            }
        }
        break;
    }
    draw_set_colour(c_white);
    exit;
}

// otherwise: the battle text, typed out
draw_set_colour(c_white);
draw_text_ext_transformed(text_x, _row(0), string_copy(text, 1, text_shown), line_h / text_scale, (display_get_gui_width() - text_x * 2) / text_scale, text_scale, text_scale, 0);