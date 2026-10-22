// the Petal Feather (this object sits just in front of Susie)
if (!feather.on) exit;

var _pulse = 0.5 + 0.5 * sin(feather.t * glow_speed);
gpu_set_blendmode(bm_add);
draw_sprite_ext(feather_sprite, 0, feather.x, feather.y, feather_scale * 1.5, feather_scale * 1.5, 0, c_white,
                feather.alpha * glow_alpha * (0.6 + 0.4 * _pulse));
gpu_set_blendmode(bm_normal);
draw_sprite_ext(feather_sprite, 0, feather.x, feather.y, feather_scale, feather_scale, 0, c_white, feather.alpha);

draw_set_color(c_white);
for (var i = 0; i < array_length(twinkles); i++)
{
    var _tw = twinkles[i];
    var _a  = sin(_tw.t / _tw.life * pi);
    draw_set_alpha(_a * feather.alpha);
    draw_twinkle(_tw.x, _tw.y, _tw.sz * _a);
}
draw_set_alpha(1);