// bullseye at the landing spot while the bomb is in the air
if (state == "toss")
{
    var _period = toss_frames / target_flashes;
    if ((timer mod _period) < _period * 0.5) // on for the first half of each blink
    {
        var _tx = round(land_x);
        var _ty = round(land_y);

        draw_set_color(target_color);
        for (var i = 0; i < target_thickness; i++)
        {
            draw_circle(_tx, _ty, target_radius - i, true);
            draw_circle(_tx, _ty, target_radius * 0.5 - i, true);
        }
        draw_circle(_tx, _ty, 2, false); // center dot
        draw_set_color(c_white);
    }
}

if (flash_timer > 0) gpu_set_fog(true, c_white, 0, 0);
draw_sprite_ext(sprite_index, image_index, round(x), round(y), image_xscale, image_yscale, image_angle, image_blend, image_alpha);
if (flash_timer > 0) gpu_set_fog(false, c_white, 0, 0);