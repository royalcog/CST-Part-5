// the warning: a red "!" flashing just inside the box on its row, on the side it's coming from
if (t <= warn_time)
{
    if ((t div 4) mod 2 == 0)
    {
        var _in = scr_get_box_interior();
        draw_set_font(fnt_determination);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(c_red);
        draw_text_transformed((dir > 0) ? _in.x1 + 12 : _in.x2 - 12, y0, "!", 2, 2, 0);
        draw_set_colour(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    exit;
}
// tail first, head on top. flipped to face where it's going
var _xs = art_scale * dir;
var _pt = piece(segs + 1);
draw_sprite_ext(spr_titanfish_tail, floor(anim) mod sprite_get_number(spr_titanfish_tail), round(_pt.x), round(_pt.y), _xs, art_scale, 0, c_white, alpha);
for (var k = segs; k >= 1; k--)
{
    var _p = piece(k);
    draw_sprite_ext(spr_titanfish_body, floor(anim + k) mod sprite_get_number(spr_titanfish_body), round(_p.x), round(_p.y), _xs, art_scale, 0, c_white, alpha);
}
var _ph = piece(0);
draw_sprite_ext(spr_titanfish_head, floor(anim) mod sprite_get_number(spr_titanfish_head), round(_ph.x), round(_ph.y), _xs, art_scale, 0, c_white, alpha);