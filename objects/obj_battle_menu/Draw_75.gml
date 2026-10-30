// over all the UI (Draw GUI End): Susie's Rude Buster on its way to something in the UI, and a smashed row's pieces
if (buster != undefined && buster.proj != undefined)
{
    var _pr = buster.proj;
    var _ps = spr_rudebuster_projectile;
    var _n  = sprite_get_number(_ps);
    for (var k = 0; k < array_length(_pr.trail); k++)
        draw_sprite_ext(_ps, floor(_pr.frame) mod _n, _pr.trail[k].x, _pr.trail[k].y, 2, 2, _pr.dir, c_white, _pr.trail[k].a * (k + 1) / array_length(_pr.trail));
    draw_sprite_ext(_ps, floor(_pr.frame) mod _n, _pr.x, _pr.y, 2, 2, _pr.dir, c_white, 1);
}
for (var k = 0; k < array_length(row_shards); k++)
{
    var _s = row_shards[k];
    draw_set_colour(_s.col);
    draw_set_alpha(_s.a);
    draw_rectangle(_s.x - _s.w / 2, _s.y - _s.h / 2, _s.x + _s.w / 2, _s.y + _s.h / 2, false);
}
draw_set_alpha(1);
draw_set_colour(c_white);


// a smashed row coming back together: its pieces flying back into place
if (row_rebuild != undefined)
{
    var _k = row_rebuild.t / row_rebuild.time;
    var _e = _k * _k * (3 - 2 * _k);
    for (var k = 0; k < array_length(row_rebuild.pieces); k++)
    {
        var _pc = row_rebuild.pieces[k];
        var _px = lerp(_pc.x0, _pc.tx, _e), _py = lerp(_pc.y0, _pc.ty, _e);
        draw_set_colour(_pc.col);
        draw_set_alpha(min(1, _k * 3));
        draw_rectangle(_px - _pc.w / 2, _py - _pc.h / 2, _px + _pc.w / 2, _py + _pc.h / 2, false);
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
}