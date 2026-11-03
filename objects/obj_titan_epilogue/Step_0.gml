t++;
black.a = approach(black.a, black.to, black.spd);

// ---------------------------------------------------------------- the steps
if (step_i < array_length(steps))
{
    var _st = steps[step_i];
    if (!step_on) { step_on = true; step_t = 0; _st.run(); }
    if (_st.until == undefined || _st.until())
    {
        step_t++;
        if (step_t > _st.wait) { step_i++; step_on = false; }
    }
}

// ---------------------------------------------------------------- Castle Town: getting up
for (var i = 0; i < array_length(people); i++)
{
    var _p = people[i];
    if (!_p.got_up && _p.up_t >= 0 && t >= _p.up_t)
    {
        _p.got_up = true;
        if (_p.up != _p.spr) audio_play_sound(snd_wing, 1, false, 0.5);
    }
}
if (phase != "top") exit;

// ---------------------------------------------------------------- the Pipis, coming down one by one
var _k = instance_find(obj_king, 0);
if (raining && _k != noone)
{
    next_drop--;
    if (next_drop <= 0 && rain_left > 0 && !covered)
    {
        drop_pipis();
        rain_left--;
        next_drop = round(lerp(pipis_gap[0], pipis_gap[1], 1 - rain_left / pipis_n));
    }
    var _settled = true;
    for (var i = 0; i < array_length(pipis); i++)
    {
        var _p = pipis[i];
        if (_p.rest) continue;
        _settled = false;
        _p.vy += pipis_grav;
        _p.y  += _p.vy;
        _p.rot += _p.vr;
        // land on the pile (or him, or the floor): the lowest of the columns it covers
        var _c = col_of(_p.x), _top = 99999;
        for (var j = _c - 2; j <= _c + 2; j++) _top = min(_top, cols[clamp(j, 0, array_length(cols) - 1)]);
        if (_p.y >= _top - pipis_half)
        {
            _p.y = _top - pipis_half;
            _p.rest = true;
            _p.rot  = (_p.rot mod 360) * 0.25;   // (settles flatter)
            for (var j = _c - 2; j <= _c + 2; j++)
            {
                var _jj = clamp(j, 0, array_length(cols) - 1);
                cols[_jj] = min(cols[_jj], _p.y - pipis_half + 6);
            }
            if (i mod 3 == 0) audio_play_sound(snd_impact, 1, false, 0.25);
        }
    }
    if (!covered && (is_buried() || rain_left <= 0) && _settled) { covered = true; raining = false; }
}

// ---------------------------------------------------------------- the push: the pile (and him) off the edge
if (pushing && !hanging && _k != noone)
{
    push_v = max(-push_max, push_v - push_acc);
    _k.x += push_v;
    for (var i = 0; i < array_length(pipis); i++)
    {
        var _p = pipis[i];
        if (!_p.rest) continue;
        _p.x   += push_v;
        _p.rot += push_v * 1.5;
        if (_p.x < edge_x - 8) { _p.rest = false; _p.vy = 0; _p.vr = random_range(-8, 8); }   // (off the edge they go)
    }
    if (_k.bbox_right < edge_x - 6)
    {
        // out of the pile, over nothing. he stays up there
        hanging = true;
        scene.pose_flip(obj_king, king_hang_spr, king_hang_xs);
        with (_k) { image_speed = 0; y -= other.king_hang_lift; }
        audio_play_sound(snd_impact, 1, false);
    }
}
// the ones off the edge, falling away
for (var i = array_length(pipis) - 1; i >= 0; i--)
{
    var _p = pipis[i];
    if (_p.rest || raining) continue;
    _p.vy += pipis_grav;
    _p.y  += _p.vy;
    _p.rot += _p.vr;
    if (_p.y > room_height + 40) array_delete(pipis, i, 1);
}