var _ox = camera_get_view_x(view_camera[0]), _oy = camera_get_view_y(view_camera[0]);

// ---------------------------------------------------------------- Castle Town, over everything
if (phase == "town")
{
    draw_set_colour(c_black);
    draw_rectangle(_ox - 8, _oy - 8, _ox + vw + 8, _oy + vh + 8, false);
    draw_set_colour(c_white);
    draw_sprite(town_sprite, 0, _ox + town_at.x, _oy + town_at.y);
    for (var i = 0; i < array_length(people); i++)
    {
        var _p   = people[i];
        var _spr = _p.got_up ? _p.up : _p.spr;
        var _img = (_spr == spr_mewmew_very_hurt_corrupted || _spr == spr_mewmew_idle_corrupted) ? t * spd_of(_spr) : 0;
        draw_feet(_spr, _img, _ox + _p.x, _oy + _p.y + sin(t / 20 + i) * _p.bob);
    }
    exit;
}

// ---------------------------------------------------------------- the Pipis, their bursts, and the heads
for (var i = 0; i < array_length(pipis); i++)
{
    var _p = pipis[i];
    draw_sprite_ext(spr_pipis, 0, _p.x, _p.y, pipis_scale, pipis_scale, _p.rot, c_white, 1);
}
for (var i = 0; i < array_length(bursts); i++)
{
    var _b = bursts[i];
    draw_sprite_ext(spr_titan_shockwave_bullet_explosion, _b.t / 3, _b.x, _b.y, 0.12, 0.12, 0, c_white, 1);
}
for (var i = 0; i < array_length(heads); i++)
{
    var _h = heads[i];
    draw_sprite_ext(head_sprite, t * spd_of(head_sprite) + i, _h.x, _h.y, head_scale, head_scale, 0, c_white, 1);
}