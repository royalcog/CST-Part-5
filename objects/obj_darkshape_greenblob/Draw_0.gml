var _bob = collected ? 0 : sin(t * 0.1);
draw_sprite_ext(spr_darkshape_transform, min(floor(f), 9), round(x), round(y + _bob), 2, 2, 0, blob_col, image_alpha);