var _spr = spr_roaringknight_sword;

for (var i = 0; i < array_length(swords); i++)
{
    var _s = swords[i];
    var _a = _s.angle + tip_angle_offset;

    if (_s.state == "charge")
    {
		var _k = clamp(_s.t / _s.charge, 0, 1);
        draw_sprite_ext(_spr, 0, _s.x, _s.y, sword_scale, sword_scale, _a, c_white, _s.alpha);

        // red builds up on top as a solid overlay (works even if the sword art is dark)
        gpu_set_fog(true, c_red, 0, 1);
        draw_sprite_ext(_spr, 0, _s.x, _s.y, sword_scale, sword_scale, _a, c_white, _s.alpha * _k);
        gpu_set_fog(false, c_black, 0, 0);
    }
    else if (_s.state == "fly")
    {
        // just a faint red silhouette + trail while it rips through
        gpu_set_fog(true, c_red, 0, 1);
        var _n = array_length(_s.trail);
        for (var j = _n - 1; j >= 0; j--)
        {
            draw_sprite_ext(_spr, 0, _s.trail[j].x, _s.trail[j].y, sword_scale, sword_scale, _a, c_white,
                flight_alpha * (1 - (j + 1) / (_n + 1)));
        }
        draw_sprite_ext(_spr, 0, _s.x, _s.y, sword_scale, sword_scale, _a, c_white, flight_alpha);
        gpu_set_fog(false, c_black, 0, 0);
    }
}