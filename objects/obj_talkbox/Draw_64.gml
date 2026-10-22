var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _scale_x = _gui_w / camera_get_view_width(view_camera[0]);
var _scale_y = _gui_h / camera_get_view_height(view_camera[0]);

var tipx, tipy;
if (instance_exists(speaker)) {
	if (global.DEBUG_BARRAGE && instance_exists(speaker) && speaker == obj_friend)
	{
	    mouth_off_x = global.dbg_friend_offx;
	    mouth_off_y = global.dbg_friend_offy;
	}

	tipx = (speaker.x - _vx) * _scale_x + mouth_off_x;
	tipy = (speaker.y - _vy) * _scale_y + mouth_off_y;
    if instance_exists(obj_tenna) && speaker == obj_tenna && !obj_tenna.use_battle_ext
    {
        tipy -= 40;
    }
} else {
    tipx = (x - _vx) * _scale_x;
    tipy = (y - _vy) * _scale_y;
}
tipx += triangle_xoff;
tipy += triangle_yoff;

var tw = _text_w_full;
var x1, x2;
if (!flip_talkbox) {
    x2 = tipx - pad_x;
    x1 = x2 - tw - pad_x;
} else {
    x1 = tipx + pad_x;
    x2 = x1 + tw + pad_x;
}
var line_count = array_length(string_split(_layout_text, "\n"));
var _single_line_offset = (line_count == 1 ? 4 : 0); // adjust 4 to taste

var y1 = tipy - _half_h + _single_line_offset;
var y2 = tipy + _half_h + _single_line_offset;

var r1x1 = x1 - pad_x_mini;
var r1y1 = y1 - pad_y - pad_y_mini;
var r1x2 = x2;
var r1y2 = y2 + pad_y + pad_y_mini;
var r2x1 = x1 - pad_x - pad_x_mini;
var r2y1 = y1 - pad_y_mini;
var r2x2 = x2 + pad_x;
var r2y2 = y2 + pad_y_mini;

draw_set_alpha(1 - dim_alpha);
draw_set_color(rect_color);
draw_rectangle(r1x1, r1y1, r1x2, r1y2, false);
draw_rectangle(r2x1, r2y1, r2x2, r2y2, false);
draw_set_alpha(1);

if (rounded_corners == true) {
    draw_sprite_ext(spr_talkbox_corner, 0, r2x1 - 9, r1y1 - 9, 1, 1, 0, c_white, 1 - dim_alpha);
    draw_sprite_ext(spr_talkbox_corner, 1, r2x2 - 9, r1y1 - 9, 1, 1, 0, c_white, 1 - dim_alpha);
    draw_sprite_ext(spr_talkbox_corner, 2, r2x1 - 9, r1y2 - 9, 1, 1, 0, c_white, 1 - dim_alpha);
    draw_sprite_ext(spr_talkbox_corner, 3, r2x2 - 9, r1y2 - 9, 1, 1, 0, c_white, 1 - dim_alpha);
}
if (triangle_sprite != -1) {
    var sx = flip_talkbox ? -1 : 1;
    draw_sprite_ext(triangle_sprite, 0, tipx, tipy, sx, 1, 0, rect_color, 1 - dim_alpha);
}

draw_set_font(txt_font);
draw_set_color(text_color);
var base_text = _layout_text;
var shown = (chars_per_s > 0) ? string_copy(base_text, 1, char_index) : base_text;
shown = string_replace_all(shown, "@", "");
if (instance_exists(obj_tenna)) shown = string_replace_all(shown, "$", "");
shown = string_replace_all(shown, "^", "");
shown = string_replace_all(shown, "`", "");
shown = string_replace_all(shown, "~", "");
shown = string_replace_all(shown, "+", "");
if (instance_exists(obj_noelle))
{
    for (var i = 0; i <= 9; i++)
    {
        shown = string_replace_all(shown, "#" + string(i), "");
    }
}
draw_text_ext(x1, y1, shown, line_sep, wrap_w);

draw_set_color(c_white);
draw_set_alpha(1);