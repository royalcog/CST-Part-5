// the swords, with afterimages once they fall
for (var i = 0; i < array_length(swords); i++)
{
    var _s = swords[i];
    if (_s.gone || _s.delay > 0) continue;
    if (_s.thrown && _s.wait > 0) continue;   // hidden inside the white streak
    if (_s.thrown)
    {
        for (var k = sword_trail; k >= 1; k--)
            draw_sprite_ext(spr_roark_sword2, 0, _s.x, _s.y - _s.vy * k * 1.5, sword_scale, sword_scale, 0, c_white,
                            _s.alpha * 0.35 * (1 - k / (sword_trail + 1)));
    }
    draw_sprite_ext(spr_roark_sword2, 0, _s.x, _s.y, sword_scale, sword_scale, 0, c_white, _s.alpha);
}

// the glints next to the Knight while the swords hang
if (snd_drop >= 0 && audio_is_playing(snd_drop))
{
    var _p = audio_sound_get_track_position(snd_drop);
    draw_set_color(c_white);
    for (var i = 0; i < array_length(glint_times); i++)
    {
        var _k = (_p - glint_times[i]) / glint_life;
        if (_k < 0 || _k >= 1) continue;
        var _sz = 7 * sin(_k * pi);
        var _w  = _sz * 0.3;
        var _gx = knight_x + glint_dx + _k * 16;
        var _gy = knight_head_y + 8;
        draw_primitive_begin(pr_trianglelist);
        draw_vertex(_gx, _gy - _sz); draw_vertex(_gx + _w, _gy); draw_vertex(_gx, _gy + _sz);
        draw_vertex(_gx, _gy - _sz); draw_vertex(_gx - _w, _gy); draw_vertex(_gx, _gy + _sz);
        draw_vertex(_gx - _sz, _gy); draw_vertex(_gx, _gy - _w); draw_vertex(_gx + _sz, _gy);
        draw_vertex(_gx - _sz, _gy); draw_vertex(_gx, _gy + _w); draw_vertex(_gx + _sz, _gy);
        draw_primitive_end();
    }
}
draw_set_color(c_white);