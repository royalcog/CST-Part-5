var _k  = art_scale * scalefactor * grow;
var _sh = (light > 0) ? random_range(-1, 1) * light : 0;   // shudders as it's purified
var _dx = round(x + _sh), _dy = round(y);
var _ang = face_dir ? dir : 0;

if (light > 0 && shrink_sprite != -1)
    draw_sprite_ext(shrink_sprite, stage, _dx, _dy, _k, _k, _ang, c_white, image_alpha);
else if (anim_sprite != -1)
    draw_sprite_ext(anim_sprite, floor(anim_f) mod sprite_get_number(anim_sprite), _dx, _dy, _k, _k, _ang, c_white, image_alpha);
else
{
    // placeholder until the sprites are in: black blob with a white outline + eyes
    var _r = radius * 0.5 * scalefactor * grow;
    draw_set_alpha(image_alpha);
    draw_set_colour(merge_colour(c_black, c_white, light));
    draw_circle(_dx, _dy, _r, false);
    draw_set_colour(c_white);
    draw_circle(_dx, _dy, _r, true);
    draw_circle(_dx - _r * 0.35, _dy - _r * 0.2, max(1, _r * 0.15), false);
    draw_circle(_dx + _r * 0.35, _dy - _r * 0.2, max(1, _r * 0.15), false);
    draw_set_alpha(1);
}