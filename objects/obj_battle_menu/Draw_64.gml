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
var _show = (state == "choose" || state == "exec_next" || state == "exec_run" || state == "fight_bars"
          || state == "fight_wait" || state == "fight_hit" || state == "win");
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

// FIGHT's timing bars
if (state == "fight_bars" || state == "fight_wait" || state == "fight_hit")
{
    for (var i = 0; i < array_length(fighters); i++)
    {
        var _f = fighters[i];
        var _y = _row(i);
        draw_set_colour(defs[_f.who].color);
        draw_text_transformed(text_x, _y, string_upper(names[_f.who]), text_scale * 0.75, text_scale * 0.75, 0);
        draw_set_colour(c_white);
        draw_rectangle(bar_x0 - 2, _y + 2, bar_x0 + 2, _y + line_h - 4, true);             // the target line
        if (!_f.done || _f.flash > 0)
        {
            var _bc = _f.crit ? col_yellow : c_white;
            draw_set_alpha(_f.done ? _f.flash : 1);
            draw_set_colour(_bc);
            draw_rectangle(_f.x - 3, _y + 2, _f.x + 3, _y + line_h - 4, false);
            draw_set_alpha(1);
        }
    }
    draw_set_colour(c_white);
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
                draw_text_transformed(_x, _y, _o.name, text_scale, text_scale, 0);
                if (i == list_i) _heart(_x - 20, _y);
            }
            var _sel = list[list_i];
            draw_set_colour(col_grey);
            draw_text_transformed(desc_x, _row(0), _sel.desc, text_scale * 0.75, text_scale * 0.75, 0);
            if (!_is_item && _sel.tp > 0)
            {
                draw_set_colour(col_orange);
                draw_text_transformed(desc_x + 140, _row(0), string(_sel.tp) + "% TP", text_scale * 0.75, text_scale * 0.75, 0);
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
                draw_text_transformed(col_x[0], _y, _en.enemy_name, text_scale, text_scale, 0);
                if (_en.can_spare && _en.is_tired()) { draw_set_colour(col_tired); draw_text_transformed(col_x[0] + 230, _y, "(Tired)", text_scale * 0.75, text_scale * 0.75, 0); }
                if (i == pick_i) _heart(col_x[0] - 20, _y);
                // HP and MERCY bars
                var _hx = 520, _mx = 680, _bw = 110, _bh = line_h - 8;
                draw_set_colour(make_color_rgb(128, 0, 0)); draw_rectangle(_hx, _y + 4, _hx + _bw, _y + 4 + _bh, false);
                draw_set_colour(make_color_rgb(0, 255, 0)); draw_rectangle(_hx, _y + 4, _hx + _bw * (_en.hp / _en.max_hp), _y + 4 + _bh, false);
                draw_set_colour(make_color_rgb(255, 80, 32)); draw_rectangle(_mx, _y + 4, _mx + _bw, _y + 4 + _bh, false);
                draw_set_colour(col_yellow); if (_en.mercy > 0) draw_rectangle(_mx, _y + 4, _mx + _bw * (_en.mercy / 100), _y + 4 + _bh, false);
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
                draw_text_transformed(col_x[0], _y, names[i], text_scale, text_scale, 0);
                draw_set_colour((_b.hp <= 0) ? c_red : c_white);
                draw_text_transformed(col_x[0] + 200, _y, "HP " + string(_b.hp) + " / " + string(_b.max_hp), text_scale, text_scale, 0);
                if (i == pick_i) _heart(col_x[0] - 20, _y);
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