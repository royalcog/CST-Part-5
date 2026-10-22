var _bs = image_yscale;
draw_sprite_ext(spr_battat, 1, x + 40, y - 40 - anim[8] * _bs, image_xscale * xscale, (image_yscale * yscale) + anim[7], image_angle, c_white,  obj_tennabg.trio_alpha);
draw_sprite_ext(spr_battat, 2, x + 40, (y - anim[8] * _bs) - 40 + anim[1] * _bs, image_xscale * xscale, image_yscale * yscale, image_angle, c_white,  obj_tennabg.trio_alpha);
draw_sprite_ext(spr_battat, 3 + clamp(talk_ind, 0, 3), x + 40, (y - anim[8] * _bs) - 40 + anim[1] * _bs, image_xscale * xscale, image_yscale * yscale, image_angle, c_white,  obj_tennabg.trio_alpha);
draw_sprite_ext(spr_battat, 7, x + 40 + anim[2] * image_xscale, (y - anim[8] * _bs) - 40 + anim[3] * _bs, image_xscale * xscale, image_yscale * yscale, image_angle, c_white,  obj_tennabg.trio_alpha);
draw_sprite_ext(spr_battat, 8, x + 40 + anim[3] * image_xscale, (y - anim[8] * _bs) - 40 + anim[2] * _bs, image_xscale * xscale, image_yscale * yscale, image_angle, c_white,  obj_tennabg.trio_alpha);
draw_sprite_ext(spr_battat, 9, x + 40, y - 40 - anim[8] * _bs, image_xscale * xscale, image_yscale * yscale, image_angle, c_white,  obj_tennabg.trio_alpha);