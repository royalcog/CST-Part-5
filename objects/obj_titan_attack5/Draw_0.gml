event_inherited();
// Ralsei's fireball
if (fireball != undefined)
{
    var _f = fireball, _n = array_length(_f.trail);
    gpu_set_blendmode(bm_add);
    for (var i = _n - 1; i >= 0; i--)
    {
        var _tr = _f.trail[i], _k = 1 - (i + 1) / (_n + 1);
        draw_sprite_ext(fb_sprite, _f.frame, _tr.x, _tr.y, fb_scale * (0.5 + 0.5 * _k), fb_scale * (0.5 + 0.5 * _k), _f.dir, c_orange, 0.5 * _k);
    }
    draw_set_alpha(0.7);
    draw_circle_colour(_f.x, _f.y, fb_glow + sin(t * 0.6) * 4, c_orange, c_black, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    draw_sprite_ext(fb_sprite, _f.frame, _f.x, _f.y, fb_scale, fb_scale, _f.dir, c_white, 1);
}
// where it hit
if (boom != undefined) draw_sprite_ext(spr_titan_shockwave_bullet_explosion, floor(boom.f), boom.x, boom.y, 0.3, 0.3, 0, c_white, 1);