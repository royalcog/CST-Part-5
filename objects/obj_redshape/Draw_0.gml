for (var i = 0; i < array_length(trail); i++)
{
    var _tr = trail[i];
    draw_sprite_ext(spr_darkshape_red, 0, round(_tr.x), round(_tr.y), art_scale, art_scale, _tr.a, c_white, _tr.al * image_alpha);
}
draw_sprite_ext(spr_darkshape_red, 0, round(x), round(y), art_scale, art_scale, angle, c_white, image_alpha);