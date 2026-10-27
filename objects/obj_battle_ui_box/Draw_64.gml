if (!instance_exists(obj_UI)) exit;

var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
var _scale_x = display_get_gui_width()  / camera_get_view_width(view_camera[0]);
var _scale_y = display_get_gui_height() / camera_get_view_height(view_camera[0]);

var _sx = (obj_UI.x + box_offset_x + obj_UI.boxes_x_correction - _vx) * _scale_x;
// once a box has locked in its attack, it stays raised (bottom half showing) for the
// rest of the round, not just while the selection sequence is still running
var _is_active = (id == obj_UI.active_box) || selected_attack;
var _rest_y = _is_active ? -active_raise_offset : inactive_rest_offset;
var _sy = (obj_UI.y + box_offset_y + _rest_y + obj_UI.boxes_y_correction - _vy) * _scale_y;
var _s  = frame_scale; // shorthand

// background frame — normal art, or the "attack" art once this box has locked in an attack;
// the hurt face is overlaid separately below either way
var _bg_frame = selected_attack ? attack_frame : sprite_frame;
var _w = sprite_get_width(_bg_frame);
draw_sprite_part_ext(_bg_frame, 0, 0, 0, _w, divider_y, _sx, _sy, _scale_x * _s, _scale_y * _s, c_white, 1);

if (selected_attack)
{
    var _bottom_h = sprite_get_height(_bg_frame) - divider_y;
    if (_bottom_h > 0)
    {
        draw_sprite_part_ext(_bg_frame, 0, 0, divider_y, _w, _bottom_h,
            _sx, _sy + divider_y * _scale_y * _s, _scale_x * _s, _scale_y * _s, c_white, 1);
    }
}

if (hurt_timer > 0)
{
    var _full_w = icon_rect_w * _scale_x * _s;
    var _full_h = icon_rect_h * _scale_y * _s;
    var _draw_w = _full_w * hurt_icon_scale;
    var _draw_h = _full_h * hurt_icon_scale;

    var _icon_base_x = _sx + icon_rect_x * _scale_x * _s;
    var _icon_base_y = _sy + icon_rect_y * _scale_y * _s;

    // erase the normal face first so the (smaller) hurt face doesn't overlap it
    draw_rectangle_color(_icon_base_x, _icon_base_y, _icon_base_x + _full_w, _icon_base_y + _full_h, c_black, c_black, c_black, c_black, false);

    draw_sprite_part_ext(hurt_frame, 0, icon_rect_x, icon_rect_y, icon_rect_w, icon_rect_h,
        _icon_base_x + (_full_w - _draw_w) / 2, _icon_base_y + (_full_h - _draw_h) / 2,
        _scale_x * _s * hurt_icon_scale, _scale_y * _s * hurt_icon_scale, c_white, 1);
}

// HP bar fill — drawn on top of the baked #4C0000 track, shrinks left-to-right with hp
var _bx = _sx + bar_offset_x * _scale_x * _s;
var _by = _sy + bar_offset_y * _scale_y * _s;
var _bw = bar_width  * _scale_x * _s;
var _bh = bar_height * _scale_y * _s;
var _pct = clamp(hp_display / max_hp, 0, 1);
draw_rectangle_color(_bx, _by, _bx + _bw * _pct, _by + _bh, bar_fill_color, bar_fill_color, bar_fill_color, bar_fill_color, false);

// HP number — current sits right-aligned before the baked slash, max sits left-aligned after it
// each digit is forced to hp_digit_w x hp_digit_h px (native), hp_digit_gap px apart
draw_set_font(hp_font);
draw_set_color(c_white); // don't inherit whatever the last GUI drawer left set (TALKbox leaves c_black)
draw_set_alpha(1);

var _cy = _sy + hp_text_offset_y * _scale_y * _s + hp_digit_y_offset * _scale_y;
var _cx = _sx + hp_current_x * _scale_x * _s;
var _mx = _sx + hp_max_x * _scale_x * _s;

var _dw   = hp_digit_w   * _scale_x;
var _dh   = hp_digit_h   * _scale_y;
var _dgap = hp_digit_gap * _scale_x;

draw_set_color(hp_display < 0 ? c_red : c_white);
scr_draw_pixel_number(_cx, _cy, string(round(hp_display)), fa_right, _dw, _dh, _dgap, hp_font_native_w, hp_font_native_h);
draw_set_color(c_white);
scr_draw_pixel_number(_mx, _cy, string(max_hp), fa_left, _dw, _dh, _dgap, hp_font_native_w, hp_font_native_h);