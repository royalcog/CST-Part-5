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

// ---------------------------------------------------------------- the text panel (Deltarune's: black, a 3px dark purple line on top)
var _show = (state == "choose" || state == "exec_next" || state == "exec_run" || state == "fight" || state == "win"
          || state == "intro_say" || state == "protect");
if (!_show) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
draw_set_colour(c_black);
draw_rectangle(0, panel_y, _gw, _gh, false);
draw_set_colour(col_strip);
draw_rectangle(0, panel_y, _gw, panel_y + 2, false);

draw_set_font(fnt_determination);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Deltarune measures everything in the panel from its action-box row, which spans its whole 640px screen.
// ours is centred on a wider screen, so everything below is shifted to the row's left edge (reset at every exit)
var _ox = instance_exists(obj_UI) ? round(obj_UI.x - 1 + obj_UI.boxes_x_correction - camera_get_view_x(view_camera[0])) : 0;
matrix_set(matrix_world, matrix_build(_ox, 0, 0, 0, 0, 0, 1, 1, 1));

// Deltarune's UI starts 37px above the panel's top line (_o). GameMaker draws this font 4px higher than Kristal does, hence the +4s
var _o   = panel_y - 37;
var _row = function(_i) { return panel_y + 17 + _i * line_h; };   // Deltarune: 50 + row * 30
// the 16px heart, its top 6px below the text's top (Deltarune: 60 + row * 30)
var _heart = function(_left, _y) { draw_sprite_ext(spr_soul_red, 0, _left + 8, _y + 14, 1, 1, 0, c_white, 1); };
// a bar with its % in the font squashed to half height (Deltarune's enemy list)
var _bar = function(_x, _y, _w, _k, _bg, _fg, _txt, _txt_col)
{
    draw_set_colour(_bg); draw_rectangle(_x, _y, _x + _w - 1, _y + 15, false);
    if (_k > 0) { draw_set_colour(_fg); draw_rectangle(_x, _y, _x + ceil(_k * _w) - 1, _y + 15, false); }
    if (_txt != "") { draw_set_colour(_txt_col); draw_text_transformed(_x + 4, _y + 2, _txt, 2, 1, 0); }
};

// FIGHT's attack boxes (Deltarune's: 36px rows, 38 apart)
if (state == "fight")
{
    // the two dark blue lines between the rows (Chapter 2 on)
    draw_set_colour(col_attack_lines);
    draw_rectangle(79, _o + 78,  79 + 223, _o + 79,  false);
    draw_rectangle(79, _o + 116, 79 + 223, _o + 117, false);

    for (var i = 0; i < array_length(fighters); i++)
    {
        var _f  = fighters[i];
        var _b  = members[_f.who];
        var _fc = fb_cols[$ names[_f.who]];
        var _y1 = panel_y + 4 + _f.who * (fb_row_h + fb_row_gap), _y2 = _y1 + fb_row_h;
        var _ym = (_y1 + _y2) / 2;

        // their face (out of their party box's art), centred on x 21
        if (_b != noone && _b.icon_rect_w > 0)
        {
            var _r  = variable_struct_exists(fb_icon_rects, names[_f.who]) ? fb_icon_rects[$ names[_f.who]]
                    : [_b.icon_rect_x, _b.icon_rect_y, _b.icon_rect_w, _b.icon_rect_h];
            var _is = fb_head_h / _r[3];
            draw_sprite_part_ext(_b.sprite_frame, 0, _r[0], _r[1], _r[2], _r[3], fb_head_x - _r[2] * _is / 2, _ym - fb_head_h / 2, _is, _is, c_white, 1);
        }
        // the box: a 2px outline in their dark colour (flashes white when Z's pressed)
        var _bx2 = fb_box_x + fb_box_w;
        draw_set_colour(merge_colour(_fc.box, c_white, fb_flash));
        draw_rectangle(fb_box_x, _y1, _bx2, _y2, true);
        draw_rectangle(fb_box_x + 1, _y1 + 1, _bx2 - 1, _y2 - 1, true);
        // the target: their colour around a black middle exactly the bolt's width
        draw_set_colour(_fc.target);
        draw_rectangle(fb_target_x - 2, _y1, fb_target_x + fb_bolt_w + 1, _y2, false);
        draw_set_colour(c_black);
        draw_rectangle(fb_target_x, _y1 + 1, fb_target_x + fb_bolt_w - 1, _y2 - 1, false);

        // the bolt: afterimages while it slides, then it bursts where it was hit
        draw_set_colour(c_white);
        for (var k = 0; k < array_length(_f.ghosts); k++)
        {
            draw_set_alpha(_f.ghosts[k].a);
            draw_rectangle(_f.ghosts[k].x, _y1 - 1, _f.ghosts[k].x + fb_bolt_w - 1, _y2 + 1, false);
        }
        draw_set_alpha(1);
        if (_f.phase == "move")
            draw_rectangle(_f.x, _y1 - 1, _f.x + fb_bolt_w - 1, _y2 + 1, false);
        else if (_f.phase != "miss" && _f.alpha > 0)
        {
            var _cx = _f.x + fb_bolt_w / 2, _hw = fb_bolt_w / 2 * _f.scale, _hh = (fb_row_h / 2 + 1) * _f.scale;
            draw_set_colour(_f.col);
            draw_set_alpha(_f.alpha);
            draw_rectangle(_cx - _hw, _ym - _hh, _cx + _hw - 1, _ym + _hh, false);
            draw_set_alpha(1);
        }
        // critical: little stars drifting off
        for (var k = 0; k < array_length(_f.stars); k++)
        {
            var _st = _f.stars[k];
            draw_sprite_ext(spr_sparestar_anim, 0, _st.x, _ym + _st.y, 1, 1, _st.x * 4, col_yellow, _st.a);
        }
        // fading out once it's all done
        if (fb_fade > 0)
        {
            draw_set_colour(c_black);
            draw_set_alpha(fb_fade);
            draw_rectangle(-_ox, _y1 - 2, _gw - _ox, _y2 + 2, false);
            draw_set_alpha(1);
        }
        draw_set_colour(c_white);
    }
    matrix_set(matrix_world, matrix_build_identity());
    exit;
}

// picking from a list / a target (and the target list while Susie's Rude Buster is on its way to a row)
var _protect_list = (state == "protect" && protect != undefined && protect.phase != "say");
if ((state == "choose" && mode != "cmd") || _protect_list)
{
    switch (_protect_list ? "enemy" : mode)
    {
        case "list":
        {
            // two columns (Deltarune: text at 30 / 260, hearts at 5 / 230)
            var _is_item = (list == items);
            for (var i = 0; i < array_length(list); i++)
            {
                var _o2 = list[i];
                var _c  = i mod 2;
                var _x = col_x[_c], _y = _row(i div 2);
                var _can = _is_item || scr_tp_can_spend(_o2.tp);
                draw_set_colour(_can ? c_white : col_grey);
                draw_text_transformed(_x, _y, _o2.name, name_scale, name_scale, 0);
                if (i == list_i) _heart(5 + _c * 225, _y);
            }
            // the description in grey at the top right, the TP cost in orange at a fixed spot under it (Deltarune's 500, 50 / 115)
            var _sel = list[list_i];
            draw_set_colour(col_grey);
            if (_sel.desc != "") draw_text_ext_transformed(desc_x, _row(0), _sel.desc, desc_line / desc_scale, 1000, desc_scale, desc_scale, 0);
            if (!_is_item && _sel.tp > 0)
            {
                draw_set_colour(col_orange);
                draw_text_transformed(desc_x, _o + 119, string(_sel.tp) + "% TP", desc_scale, desc_scale, 0);
            }
        }
        break;

        case "enemy":
        {
            // Deltarune: heart at 55, names at 80, "HP" / "MERCY" (half height) over 81x16 bars at 420 / 520
            var _e = enemies();
            draw_set_colour(c_white);
            draw_text_transformed(424, _o + 41, "HP", 2, 1, 0);
            draw_text_transformed(524, _o + 41, "MERCY", 2, 1, 0);
            for (var i = 0; i < array_length(_e); i++)
            {
                var _en = _e[i];
                var _y = _row(i);
                if (row_broken(_en)) continue;   // smashed: just its empty slot
                draw_set_colour((_en.can_spare && _en.mercy >= 100) ? col_yellow : c_white);
                draw_text_transformed(80, _y, _en.enemy_name, name_scale, name_scale, 0);
                if (_en.can_spare && _en.is_tired()) { draw_set_colour(col_tired); draw_text_transformed(80 + string_width(_en.enemy_name) * name_scale + 20, _y, "(Tired)", name_scale, name_scale, 0); }
                if (i == pick_i) _heart(55, _y);
                _bar(420, _y + 1, 81, _en.hp / _en.max_hp, col_hp_bg, col_hp, string(ceil(_en.hp / _en.max_hp * 100)) + "%", c_white);
                if (_en.can_spare)
                    _bar(520, _y + 1, 81, _en.mercy / 100, col_mercy_bg, col_yellow, string(_en.mercy) + "%", col_mercy_text);
                else
                {
                    // can't be spared: Deltarune crosses its MERCY bar out
                    _bar(520, _y + 1, 81, 0, col_mercy_bg, col_yellow, "", c_white);
                    draw_set_colour(col_mercy_text);
                    draw_line_width(520, _y + 2, 520 + 81, _y + 1 + 15, 2);
                    draw_line_width(520, _y + 1 + 15, 520 + 81, _y + 2, 2);
                }
            }
        }
        break;

        case "ally":
        {
            // Deltarune: names at 80, a 101x16 HP bar at 400
            for (var i = 0; i < 3; i++)
            {
                var _b = members[i];
                if (_b == noone) continue;
                var _y = _row(i);
                draw_set_colour(c_white);
                draw_text_transformed(80, _y, names[i], name_scale, name_scale, 0);
                _bar(400, _y + 1, 101, max(0, _b.hp / _b.max_hp), col_hp_bg, col_hp, "", c_white);
                if (i == pick_i) _heart(55, _y);
            }
        }
        break;
    }
    draw_set_colour(c_white);
    matrix_set(matrix_world, matrix_build_identity());

    for (var k = 0; k < array_length(row_shards); k++)
    {
        var _s = row_shards[k];
        draw_set_colour(_s.col);
        draw_set_alpha(_s.a);
        draw_rectangle(_s.x - _s.w / 2, _s.y - _s.h / 2, _s.x + _s.w / 2, _s.y + _s.h / 2, false);
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
    exit;
}

// otherwise: the battle text, typed out (Deltarune: x 30, 28px lines, wraps at 580 wide).
// someone talking in the panel: their face on the left, the text moved over next to it
draw_set_colour(c_white);
var _tx0 = text_x;
if (text_face != undefined)
{
    draw_sprite_ext(text_face.spr, text_face.img, face_x + sprite_get_xoffset(text_face.spr) * face_scale,
        panel_y + face_y + sprite_get_yoffset(text_face.spr) * face_scale, face_scale, face_scale, 0, c_white, 1);
    _tx0 += say_indent;
}
var _shown = floor(text_shown);
for (var i = 0; i < array_length(text_lines); i++)
{
    var _l   = text_lines[i];
    var _vis = clamp(_shown - _l.from + 1, 0, _l.len);
    if (_vis > 0) draw_text_transformed(_tx0 + _l.x, panel_y + 18 + _l.y, string_copy(text, _l.from, _vis), text_scale, text_scale, 0);
}
matrix_set(matrix_world, matrix_build_identity());