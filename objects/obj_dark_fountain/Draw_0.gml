var _tw = sprite_get_width(spr_fountain)  * scale;
var _th = sprite_get_height(spr_fountain) * scale;
var _w  = _tw;
var _h  = max(1, round(y - top_y));
var _x0 = floor(x - _w / 2);   // whole pixels, so the surface and the rim line up exactly
var _ty = floor(top_y);

if (!surface_exists(surf) || surface_get_width(surf) != _w || surface_get_height(surf) != _h)
{
    if (surface_exists(surf)) surface_free(surf);
    surf = surface_create(_w, _h);
}

var _ox = sprite_get_xoffset(spr_fountain) * scale;
var _oy = sprite_get_yoffset(spr_fountain) * scale;

surface_set_target(surf);
draw_clear_alpha(c_black, 1);

// two layers of the texture, both rising
draw_sprite_tiled_ext(spr_fountain, 0, _ox, _oy - (scroll mod _th), scale, scale, make_color_hsv(hue, sat, 255), 1);
gpu_set_blendmode(bm_add);
draw_sprite_tiled_ext(spr_fountain, 0, _ox + _tw / 2, _oy - (scroll2 mod _th) + _th / 3, scale, scale,
                      make_color_hsv((hue + hue_gap) mod 255, sat, 255), layer2_alpha);

// cut everything outside the U away: any base-sprite pixel that isn't (nearly) see-through
// clears the texture completely, even its half-transparent right edge
var _bx = _w / 2;
var _by = _h - (sprite_get_height(spr_fountain_bottom) - sprite_get_yoffset(spr_fountain_bottom)) * scale;
gpu_set_alphatestenable(true);
gpu_set_alphatestref(16);                  // pixels below this alpha (the inside of the U) are left alone
gpu_set_blendmode_ext(bm_zero, bm_zero);   // everything else -> fully transparent
draw_sprite_ext(spr_fountain_bottom, 0, _bx, _by, scale, scale, 0, c_white, 1);
gpu_set_alphatestenable(false);
gpu_set_blendmode(bm_normal);
surface_reset_target();

draw_surface(surf, _x0, _ty);

// the glowing rim: additive, so the sprite's black does nothing and only the white edge shows
gpu_set_blendmode(bm_add);
draw_sprite_ext(spr_fountain_bottom, 0, _x0 + _bx, _ty + _by, scale, scale, 0, c_white, 1);
gpu_set_blendmode(bm_normal);