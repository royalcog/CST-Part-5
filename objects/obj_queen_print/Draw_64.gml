if (reveal_height > 0)
{
    var _g = scr_room_to_gui(x, y);

    var _draw_x = _g.x - sprite_get_xoffset(print_spr) * x_scale * _g.sx;
    var _draw_y = _g.y - sprite_get_yoffset(print_spr) * y_scale * _g.sy;

    draw_sprite_part_ext(print_spr, print_index, 0, 0, print_width, reveal_height,
        _draw_x, _draw_y, x_scale * _g.sx, y_scale * _g.sy, c_white, 1);
}