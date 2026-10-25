if (warn_t > 0 || !is_struct(arena)) exit;
// sideways: flipped to face where it's going. up/down: turned to face down (or up)
var _xs  = vert ? scale : scale * dir;
var _ang = vert ? ((dir > 0) ? 270 : 90) : 0;

// each piece drawn wherever it is round the tower (so it can swim across the seam). tail first, head on top
var _pt = piece(segs + 1);
draw_sprite_ext(spr_titanfish_tail, floor(anim) mod sprite_get_number(spr_titanfish_tail), scr_plat_draw_x(arena.cx + _pt.ox), _pt.y, _xs, scale, _ang, c_white, alpha);
for (var k = segs; k >= 1; k--)
{
    var _p = piece(k);
    draw_sprite_ext(spr_titanfish_body, floor(anim + k) mod sprite_get_number(spr_titanfish_body), scr_plat_draw_x(arena.cx + _p.ox), _p.y, _xs, scale, _ang, c_white, alpha);
}
var _ph = piece(0);
draw_sprite_ext(spr_titanfish_head, floor(anim) mod sprite_get_number(spr_titanfish_head), scr_plat_draw_x(arena.cx + _ph.ox), _ph.y, _xs, scale, _ang, c_white, alpha);