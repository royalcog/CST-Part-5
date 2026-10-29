var _k = art_scale * min(1, 0.5 + 0.5 * t / appear_time);   // grows in as it appears
draw_sprite_ext(spr_darkshape_red, 0, round(x), round(y), _k, _k, dir, c_white, image_alpha);