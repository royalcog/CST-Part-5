if (surface_exists(tail_surf))
{
    var _p = scr_room_to_gui(pivot_x, pivot_y);

    draw_surface_ext(
        tail_surf,
        _p.x - tail_surf_size * _p.sx / 2,
        _p.y - tail_surf_size * _p.sy / 2,
        _p.sx,
        _p.sy,
        _p.angle,
        c_white,
        1
    );
}