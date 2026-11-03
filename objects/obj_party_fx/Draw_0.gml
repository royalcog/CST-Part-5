switch (kind)
{
    case "bomb":
        if (state == "fly") draw_sprite_ext(spr_pinkbomb, 0, px, py, bomb_scale, bomb_scale, rot, c_white, 1);
    break;
    case "spade":
        if (state == "grow" || state == "hover" || state == "shoot") draw_sprite_ext(spr_spade, 0, px, py, scale, scale, rot, c_white, 1);
    break;
    case "pipis":
        for (var i = 0; i < array_length(pipis); i++)
        {
            var _p = pipis[i];
            if (!_p.done && _p.delay <= 0) draw_sprite_ext(spr_pipis, 0, _p.x, _p.y, pipis_scale, pipis_scale, _p.rot, c_white, 1);
        }
    break;
}
for (var i = 0; i < array_length(booms); i++)
{
    var _m = booms[i];
    draw_sprite_ext(_m.spr, floor(_m.f), _m.x, _m.y, _m.s, _m.s, _m.ang, c_white, 1);
}
for (var i = 0; i < array_length(bits); i++)
{
    var _b = bits[i];
    draw_sprite_ext(spr_spadechunk, 0, _b.x, _b.y, 0.35, 0.35, _b.rot, c_white, 1 - _b.t / 30);
}