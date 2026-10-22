/// scr_draw_pixel_number(_x, _y, _text, _halign, _digit_w, _digit_h, _digit_gap, _native_w, _native_h)
///
/// Draws a string of digits so each character's actual ink is forced to an
/// exact _digit_w x _digit_h pixel size, with exactly _digit_gap pixels
/// between one digit's ink and the next's. The font must already be set
/// with draw_set_font() before calling this.
///
/// _native_w/_native_h are the current font's own baked digit ink size
/// (native px, before any scaling) — the reference size we scale down (or
/// up) from to hit _digit_w x _digit_h exactly. This differs per font, so
/// the caller passes whatever's right for whichever font is set.
///
/// _halign: fa_left (anchor _x at the left edge) or fa_right (anchor _x at
/// the right edge, growing left) — vertical alignment is left to the caller
/// via _y, same as before.
function scr_draw_pixel_number(_x, _y, _text, _halign, _digit_w, _digit_h, _digit_gap, _native_w, _native_h)
{
    var _scale_x = _digit_w / _native_w;
    var _scale_y = _digit_h / _native_h;

    var _len = string_length(_text);
    // snap the cell size to whole pixels so every digit lands on the same pixel grid —
    // otherwise two instances of the same glyph can round differently depending on
    // where they fall subpixel-wise, and end up looking like different shapes
    var _cell_w = round(_digit_w);
    var _cell_gap = round(_digit_gap);
    var _pitch = _cell_w + _cell_gap;
    var _total_w = (_len * _cell_w) + (max(0, _len - 1) * _cell_gap);

    var _start_x = round((_halign == fa_right) ? (_x - _total_w) : _x);
    var _draw_y = round(_y);

    var _prev_halign = draw_get_halign();
    draw_set_halign(fa_left);

    // pixel-art font: force nearest-neighbor sampling so the bitmap scales identically
    // every time, instead of bilinear-smoothing each digit slightly differently
    var _prev_filter = gpu_get_texfilter();
    gpu_set_texfilter(false);

    for (var _i = 1; _i <= _len; _i++)
    {
        var _ch = string_char_at(_text, _i);
        draw_text_transformed(_start_x + (_i - 1) * _pitch, _draw_y, _ch, _scale_x, _scale_y, 0);
    }

    gpu_set_texfilter(_prev_filter);
    draw_set_halign(_prev_halign);
}