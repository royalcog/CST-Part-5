// shudders while it's hurt (without actually moving)
var _sx = 0;
if (hurt_t > 0) _sx = ((hurt_t div 2) mod 2 == 0 ? 1 : -1) * hurt_shake * (hurt_t / hurt_len);
var _dx = scr_plat_draw_x(x) + _sx;
var _a  = image_alpha * min(1, appear_t / appear_len);

if (invincible)
{
    // glowing rainbow: a colour-cycling glow behind it, and tinted itself
    var _col = make_colour_hsv((current_time / 4) mod 256, 190, 255);
    var _pulse = 1.2 + 0.08 * sin(current_time / 90);
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, _dx, y, image_xscale * _pulse, image_yscale * _pulse, 0, _col, _a * 0.7);
    gpu_set_blendmode(bm_normal);
    draw_sprite_ext(sprite_index, image_index, _dx, y, image_xscale, image_yscale, 0, merge_colour(c_white, _col, 0.55), _a);
}
else draw_sprite_ext(sprite_index, image_index, _dx, y, image_xscale, image_yscale, 0, image_blend, _a);