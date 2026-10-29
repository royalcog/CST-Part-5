if (collected)
{
    // a little yellow burst where it was picked up
    draw_set_colour(c_yellow);
    draw_set_alpha(1 - ring / 10);
    draw_circle(round(x), round(y), 2 + ring * 0.8, true);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    exit;
}
draw_sprite_ext(spr_darkshape_transform, floor(f), round(x), round(y), scale, scale, 0, col, image_alpha);