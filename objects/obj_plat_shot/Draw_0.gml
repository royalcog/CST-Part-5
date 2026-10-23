// drawn on whichever side of the tower's seam is on screen
var _ox = scr_plat_draw_x(x) - x;

// the Rude Buster leaves a few fading afterimages
if (kind == "buster")
{
    for (var i = array_length(trail) - 1; i >= 0; i--)
    {
        var _p = trail[i];
        draw_sprite_ext(sprite_index, image_index, scr_plat_draw_x(_p.x), _p.y, image_xscale, image_yscale, _p.a, c_white,
                        0.35 * (1 - (i + 1) / (trail_len + 1)));
    }
}
draw_sprite_ext(sprite_index, image_index, x + _ox, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);