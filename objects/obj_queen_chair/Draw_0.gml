// the fireball first (behind), lined up on the chair's canvas, then the chair
var _top  = y - sprite_get_yoffset(sprite_index) * image_yscale;
var _left = x - sprite_get_xoffset(sprite_index) * image_xscale;
var _fy   = _top + sprite_get_yoffset(flame_sprite) * image_yscale;
draw_sprite_ext(flame_sprite, floor(flame_frame) mod sprite_get_number(flame_sprite),
                _left + sprite_get_xoffset(flame_sprite) * image_xscale, _fy,
                image_xscale, image_yscale * flame_yscale, 0, c_white, flame_alpha);
draw_self();