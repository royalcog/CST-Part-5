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

// ---------------------------------------------------------------- the Pipis
var _k = instance_find(obj_king, 0);
if (_k == noone || pstate == "") exit;
stage_t++;

// falling ones: gravity, all the way down to the floor (a bounce or two, then they lie there)
for (var i = 0; i < array_length(pipis); i++)
{
    var _p = pipis[i];
    if (_p.rest) continue;
    _p.vy  += pipis_grav;
    _p.x   += _p.vx;
    _p.y   += _p.vy;
    _p.rot += _p.vr;
    if (_p.y >= _p.fy)
    {
        _p.y = _p.fy;
        if (_p.vy > 3)
        {
            // bounce
            _p.vy = -_p.vy * pipis_bounce;
            _p.vx = random_range(-1.5, 1.5);
            _p.vr = _p.vx * 5;
            land_sound();
        }
        else
        {
            _p.rest = true;
            _p.vx = 0; _p.vy = 0;
            _p.rot = (_p.rot mod 360) * 0.25;   // (settles flatter)
        }
    }
}

switch (pstate)
{
    case "rain":   // they come down, quicker and quicker, until they're all down
    {
        next_drop--;
        if (next_drop <= 0 && rain_left > 0)
        {
            var _n = (rain_left < pipis_n / 4) ? pipis_burst : 1;
            repeat (min(_n, rain_left)) { drop_pipis(); rain_left--; }
            next_drop = max(1, round(lerp(pipis_gap[0], pipis_gap[1], 1 - rain_left / pipis_n)));
        }
        var _all = true;
        for (var i = 0; i < array_length(pipis); i++) if (!pipis[i].rest) { _all = false; break; }
        if (rain_left <= 0 && _all) { pstate = "hold"; stage_t = 0; }
    }
    break;

    case "hold":   // the pile sits there a moment
        if (stage_t >= pile_hold) { pstate = "pop"; stage_t = 0; _k.visible = true; }
    break;

    case "pop":   // they burst, a few a frame, into little heads
        for (var i = 0; i < pop_rate; i++) pop_one(i == 0);
        if (array_length(pipis) == 0) { pstate = "settle"; stage_t = 0; }
    break;

    case "settle":   // the heads land
        if (stage_t >= 30) { form_wall(); pstate = "form"; stage_t = 0; }
    break;

    case "form":   // they hop into a wall on his right
        if (stage_t mod 6 == 0) { var _v = audio_play_sound(snd_spamton, 1, false, 0.4); audio_sound_pitch(_v, random_range(0.9, 1.4)); }
        if (stage_t >= form_time + array_length(heads) * form_stagger + 10) { pstate = "ready"; stage_t = 0; }
    break;

    case "push":   // the wall shoves him off the edge, and stops dead at it
    {
        push_v = min(push_max, push_v + push_acc);
        wall_x = max(edge_x, wall_x - push_v);
        if (_k.bbox_right > wall_x - 2) _k.x -= _k.bbox_right - (wall_x - 2);
        if (stage_t mod 10 == 0) { var _rs = audio_play_sound(snd_impact, 1, false, 0.35); audio_sound_pitch(_rs, random_range(0.5, 0.7)); }
        if (wall_x <= edge_x && _k.bbox_right <= edge_x)
        {
            // over nothing. he stays up there (still kneeling, right where he was)
            pstate  = "hang";
            hanging = true;
            audio_play_sound(snd_impact, 1, false);
        }
    }
    break;
}

// the heads: flying out of the bursts and bouncing on the floor, then hopping into the wall (and moving with it)
for (var i = array_length(heads) - 1; i >= 0; i--)
{
    var _h = heads[i];
    if (_h.away)
    {
        _h.vy += pipis_grav; _h.x += _h.vx; _h.y += _h.vy;
        if (_h.y > room_height + 60) array_delete(heads, i, 1);
        continue;
    }
    if (pstate == "pop" || pstate == "settle")
    {
        _h.vy += pipis_grav; _h.x += _h.vx; _h.y += _h.vy;
        var _fy = floor_y - sprite_get_height(head_sprite) * head_scale / 2;
        if (_h.y > _fy) { _h.y = _fy; _h.vy = -_h.vy * head_bounce; _h.vx *= 0.7; }
    }
    else if (_h.slot >= 0)
    {
        var _k2 = (pstate == "form") ? clamp((stage_t - _h.slot * form_stagger) / form_time, 0, 1) : 1;
        _h.x = lerp(_h.x0, slot_x(_h.slot), _k2);
        _h.y = lerp(_h.y0, slot_y(_h.slot), _k2) - sin(_k2 * pi) * 40;
    }
}
for (var i = array_length(bursts) - 1; i >= 0; i--) { bursts[i].t++; if (bursts[i].t >= 30) array_delete(bursts, i, 1); }