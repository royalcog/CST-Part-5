// shudders while it's hurt (without actually moving)
var _sx = 0;
if (hurt_t > 0) _sx = ((hurt_t div 2) mod 2 == 0 ? 1 : -1) * hurt_shake * (hurt_t / hurt_len);
draw_sprite_ext(sprite_index, image_index, scr_plat_draw_x(x) + _sx, y, image_xscale, image_yscale, 0, image_blend, image_alpha * min(1, appear_t / appear_len));