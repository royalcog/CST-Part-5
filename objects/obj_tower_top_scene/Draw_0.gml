// the ambush's spades (spinning) and the bits they break into
for (var i = 0; i < array_length(spades); i++)
{
    var _s = spades[i];
    if (_s.delay > 0) continue;
    draw_sprite_ext(spr_spade, 0, _s.x, _s.y, spade_scale, spade_scale, _s.rot, c_white, 1);
}
for (var i = 0; i < array_length(chunks); i++)
{
    var _c = chunks[i];
    draw_sprite_ext(spr_spadechunk, 0, _c.x, _c.y, 0.35, 0.35, _c.rot, c_white, 1 - _c.t / 30);
}