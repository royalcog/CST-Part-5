var _sx = (hurt_t > 0) ? random_range(-1, 1) * 4 * (hurt_t / hurt_len) : 0;
draw_sprite_ext(sprite_index, image_index, x + _sx, y, image_xscale, image_yscale, 0, image_blend, image_alpha);

// spared: whitens as it fades. targeted by the menu: a white flash pulsing over it
var _w = spared ? min(1, gone_t / 10) : (targeted ? 0.35 + 0.25 * sin(current_time / 120) : 0);
if (_w > 0)
{
    gpu_set_fog(true, c_white, 0, 0);
    draw_sprite_ext(sprite_index, image_index, x + _sx, y, image_xscale, image_yscale, 0, c_white, image_alpha * _w);
    gpu_set_fog(false, c_white, 0, 0);
}