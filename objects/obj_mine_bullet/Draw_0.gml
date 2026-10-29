var _k  = min(1, t / 20);   // eases into shape over 20 frames  [DR 10]
var _xs = lerp(0.25, 1, _k);
var _ys = lerp(flip, sign(flip), _k);
draw_sprite_ext(spr_darkshape_mine_bullet, floor(t * 0.25) mod sprite_get_number(spr_darkshape_mine_bullet),
    round(x), round(y), _xs, _ys, dir, c_white, image_alpha);