var _bob = sin(t * 0.1);
if (blob_sprite != -1)
{
    var _f = min(floor(t * 0.25), sprite_get_number(blob_sprite) - 1);   // plays the transform once, then holds
    draw_sprite_ext(blob_sprite, _f, round(x), round(y + _bob), 2, 2, 0, c_white, image_alpha);
}
else
{
    draw_set_alpha(image_alpha);
    draw_set_colour(c_yellow);
    draw_circle(round(x), round(y + _bob), 3, false);
    draw_set_colour(c_white);
    draw_set_alpha(1);
}