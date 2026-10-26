var _sx = (hurt_t > 0) ? random_range(-1, 1) * 4 * (hurt_t / hurt_len) : 0;

// ---------------- defeated: red, then sliced into drifting strips + red mist
if (gone && !spared)
{
    if (gone_t <= die_red_time)
    {
        // going red and shuddering
        var _k = gone_t / die_red_time;
        var _shake = random_range(-2, 2);
        draw_sprite_ext(sprite_index, image_index, x + _shake, y, image_xscale, image_yscale, 0, c_white, 1);
        gpu_set_fog(true, c_red, 0, 0);
        draw_sprite_ext(sprite_index, image_index, x + _shake, y, image_xscale, image_yscale, 0, c_white, _k);
        gpu_set_fog(false, c_white, 0, 0);
    }
    else
    {
        // sliced: every strip slides left or right (alternating), further and fainter as it goes
        var _k = clamp((gone_t - die_red_time) / die_slice_time, 0, 1);
        var _w = sprite_get_width(sprite_index), _h = sprite_get_height(sprite_index);
        var _left = x - sprite_get_xoffset(sprite_index) * image_xscale;   // (image_xscale can be negative: it still lines up)
        var _top  = y - sprite_get_yoffset(sprite_index) * image_yscale;
        gpu_set_fog(true, c_red, 0, 0);
        for (var _sy = 0; _sy < _h; _sy += die_strip_h)
        {
            var _dir = ((_sy div die_strip_h) mod 2 == 0) ? 1 : -1;
            var _off = _dir * die_drift * _k * _k * (0.6 + 0.4 * ((_sy * 7) mod 5) / 4);
            draw_sprite_part_ext(sprite_index, image_index, 0, _sy, _w, die_strip_h, _left + _off, _top + _sy * image_yscale,
                image_xscale, image_yscale, c_white, 1 - _k);
        }
        gpu_set_fog(false, c_white, 0, 0);
    }
    // the mist
    draw_set_colour(c_red);
    for (var i = 0; i < array_length(mist); i++)
    {
        var _m = mist[i];
        draw_set_alpha(_m.a * 0.7);
        draw_circle(_m.x, _m.y, _m.sz, false);
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
    exit;
}

draw_sprite_ext(sprite_index, image_index, x + _sx, y, image_xscale, image_yscale, 0, image_blend, image_alpha);

// spared: whitens as it fades, stars burst out. targeted by the menu: a white flash pulsing over it
var _w = spared ? min(1, gone_t / 10) : (targeted ? 0.35 + 0.25 * sin(current_time / 120) : 0);
if (_w > 0)
{
    gpu_set_fog(true, c_white, 0, 0);
    draw_sprite_ext(sprite_index, image_index, x + _sx, y, image_xscale, image_yscale, 0, c_white, image_alpha * _w);
    gpu_set_fog(false, c_white, 0, 0);
}
for (var i = 0; i < array_length(stars); i++)
{
    var _s = stars[i];
    draw_sprite_ext(spr_sparestar_anim, min(floor(_s.f), sprite_get_number(spr_sparestar_anim) - 1), _s.x, _s.y, 2, 2, _s.rot, c_white, max(0, 1 - gone_t / 45));
}