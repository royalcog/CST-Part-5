// the white graze shell around the soul, fading out once you stop grazing
if (!instance_exists(obj_soul)) exit;
var _g = global.tp.grazing;
if (_g >= shell_fade) exit;
var _s = instance_find(obj_soul, 0);
var _a = 1 - _g / shell_fade;
draw_sprite_ext(_s.sprite_index, _s.image_index, round(_s.x), round(_s.y),
    _s.image_xscale * shell_scale, _s.image_yscale * shell_scale, 0, c_white, _a * 0.8);