var _sw = sprite_get_width(sprite_index);
var _sh = sprite_get_height(sprite_index);

var _count_h = ceil((len_h / 2) / _sh);
for (var i = -_count_h; i <= _count_h; i++)
{
    draw_sprite_ext(sprite_index, image_index, x + i * _sh, y, 1, 1, 90, beam_color, image_alpha);
}

var _count_v = ceil((len_v / 2) / _sh);
for (var i = -_count_v; i <= _count_v; i++)
{
    draw_sprite_ext(sprite_index, image_index, x, y + i * _sh, 1, 1, 0, beam_color, image_alpha);
}