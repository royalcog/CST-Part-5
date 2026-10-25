for (var i = 0; i < array_length(rocks); i++)
{
    var _r = rocks[i];
    if (_r.warn > 0) continue;
    draw_sprite_ext(spr_tower_handburst_debris_isolated, _r.img, scr_plat_draw_x(_r.x), _r.y, scale, scale, _r.rot, c_white, 1);
}