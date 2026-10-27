if (slide <= 0) exit;
var _ox  = -slide_dist * (1 - slide);
var _tp  = global.tp;
var _dark = _tp.dark;
var _bx = bar_x + _ox, _by = bar_y;

// the bar's back (frame 1: dark red, frame 2: dark blue for darkness), then the fill from the bottom up
draw_sprite(spr_tensionbar, _dark ? 2 : 1, _bx, _by);
var _h   = sprite_get_height(spr_tension_filling);
var _top = 5, _bot = 192;                       // where the fill's pixels start and end in the sprite
var _fh  = (_bot - _top) * clamp(shown_tp / 100, 0, 1);
if (_fh > 0)
{
    var _sy  = _bot - _fh;                      // first row of the sprite to draw
    var _left = _bx - sprite_get_xoffset(spr_tension_filling);
    var _ty   = _by - sprite_get_yoffset(spr_tension_filling) + _sy;
    var _w    = sprite_get_width(spr_tension_filling);
    if (_dark) draw_sprite_part_ext(spr_tension_filling, 2, 0, _sy, _w, _fh, _left, _ty, 1, 1, fill_col_dark, 1);
    else       draw_sprite_part(spr_tension_filling, 0, 0, _sy, _w, _fh, _left, _ty);
    // white flash over it when you gain
    if (_tp.flash > 0) draw_sprite_part_ext(spr_tension_filling, 2, 0, _sy, _w, _fh, _left, _ty, 1, 1, c_white, _tp.flash * 0.6);
}
// the outline on top
draw_sprite(spr_tensionbar, 0, _bx, _by);

// COURAGE pickup glow: the bar's fill flashes white, and "TP" + the number get a white outline (Deltarune's)
if (glow > 0)
{
    draw_sprite_ext(spr_tension_filling, 2, _bx, _by, 1, 1, 0, c_white, 0.75 * glow);
    gpu_set_blendmode(bm_add);
    draw_set_font(fnt_determination);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
    draw_set_alpha(0.75 * glow);
    for (var _dx = -1; _dx <= 1; _dx++) for (var _dy = -1; _dy <= 1; _dy++)
    {
        if (_dx == 0 && _dy == 0) continue;
        draw_sprite_ext(spr_tensionlogo, 0, logo_x + _ox + _dx, logo_y + _dy, 1, 1, 0, c_white, 0.75 * glow);
        if (floor(_tp.value) >= 100)
        {
            var _m = ["M", "A", "X"];
            for (var k = 0; k < 3; k++) draw_text_transformed(max_spots[k][0] + _ox + _dx, max_spots[k][1] + _dy, _m[k], num_scale, num_scale, 0);
        }
        else
        {
            draw_text_transformed(num_x + _ox + _dx, num_y + _dy, string(floor(_tp.value)), num_scale, num_scale, 0);
            draw_text_transformed(pct_x + _ox + _dx, pct_y + _dy, "%", num_scale, num_scale, 0);
        }
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
// the stars
for (var i = 0; i < array_length(stars); i++)
{
    var _s = stars[i];
    draw_sprite_ext(spr_sparestar_anim, floor(_s.f) mod sprite_get_number(spr_sparestar_anim), _s.x + _ox, _s.y, 1, 1, 0, c_white, _s.a);
}

// "TP" and the number (or MAX)
draw_sprite(spr_tensionlogo, 0, logo_x + _ox, logo_y);
draw_set_font(fnt_determination);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _pct = floor(_tp.value);
if (_pct >= 100)
{
    draw_set_colour(max_col);
    var _m = ["M", "A", "X"];
    for (var i = 0; i < 3; i++) draw_text_transformed(max_spots[i][0] + _ox, max_spots[i][1], _m[i], num_scale, num_scale, 0);
}
else
{
    draw_set_colour(c_white);
    draw_text_transformed(num_x + _ox, num_y, string(_pct), num_scale, num_scale, 0);
    draw_text_transformed(pct_x + _ox, pct_y, "%", num_scale, num_scale, 0);
}
draw_set_colour(c_white);