if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    image_alpha -= 0.1;
    for (var i = 0; i < array_length(segs); i++) with (segs[i].orb) fading = true;
    if (image_alpha <= 0) instance_destroy();
    exit;
}

t++;
// fades in (flickering in size), already swimming
image_alpha = min(1, image_alpha + 0.0175);   // DR 0.035
grow = (image_alpha < 1) ? image_alpha + ((t div 2) mod 2) * 0.1 : 1;
pop  = lerp(pop, 1, 0.125);

// swims in surges (DR: 4.25 +- 2.125 at 30fps), turning toward the SOUL: the faster it's going, the wider it turns
if (!dying)
{
    spd = 2.125 + sin(t * 0.05625) * 1.0625;
    // a low rumble every time the fish surge back up (DR plays it once for all of them, at 0.35 pitch)
    if (spd < 1.25) surging = false;
    else if (!surging)
    {
        if (!rumbled) audio_play_sound(snd_screenshake_bc, 1, false, 1, 0, 0.35);   // only as it first surges in
        with (obj_darkshape_fish) { surging = true; rumbled = true; }
    }
    tracking = scr_approach(tracking, tracking_max, 0.01875);
    if (instance_exists(obj_soul))
    {
        var _turn = tracking / (spd * 2 * 1.8) / 2;
        heading += clamp(angle_difference(point_direction(x, y, obj_soul.x, obj_soul.y), heading), -_turn, _turn);
    }
    x += lengthdir_x(spd, heading);
    y += lengthdir_y(spd, heading);
}

// the body follows the exact path the head took
array_insert(hist, 0, { x: x, y: y });
if (array_length(hist) > 600) array_resize(hist, 600);
parts = [{ x: x, y: y, a: heading }];
var _need = spacing, _acc = 0, _px = x, _py = y;
for (var h = 1; h < array_length(hist) && array_length(parts) <= array_length(segs); h++)
{
    _acc += point_distance(_px, _py, hist[h].x, hist[h].y);
    _px = hist[h].x;
    _py = hist[h].y;
    if (_acc >= _need)
    {
        var _prev = parts[array_length(parts) - 1];
        array_push(parts, { x: _px, y: _py, a: point_direction(_px, _py, _prev.x, _prev.y) });
        _need += spacing;
    }
}
// purified pieces' orbs ride along in their spot
for (var i = 0; i < array_length(segs); i++)
    if (instance_exists(segs[i].orb) && i + 1 < array_length(parts)) { segs[i].orb.x = parts[i + 1].x; segs[i].orb.y = parts[i + 1].y; }

var _aura = instance_exists(ctrl) ? ctrl.aura_radius : 48;
var _sx = instance_exists(obj_soul) ? obj_soul.x : -9999;
var _sy = instance_exists(obj_soul) ? obj_soul.y : -9999;

// the head purifies in the light
if (!dying)
{
    if (point_distance(x, y, _sx, _sy) < _aura + 8) { light = scr_approach(light, 1, head_rate + head_rate * (0.5 - light)); lit_fx(x, y); }
    else light = scr_approach(light, 0, recover + recover * (0.5 - light));
}

// so does each body piece, on its own (or all by themselves, in a ripple, once the head's gone)
for (var i = 0; i < array_length(segs); i++)
{
    var _s = segs[i];
    if (instance_exists(_s.orb) || i + 1 >= array_length(parts)) continue;
    var _p = parts[i + 1];
    var _auto = (_s.auto >= 0 && die_t >= _s.auto);
    if (_auto || point_distance(_p.x, _p.y, _sx, _sy) < _aura + 8)
    {
        _s.light = scr_approach(_s.light, 1, piece_rate * (_auto ? 2 : 1) + piece_rate * (0.5 - _s.light));
        if (!_auto) lit_fx(_p.x, _p.y);
    }
    else _s.light = scr_approach(_s.light, 0, recover + recover * (0.5 - _s.light));

    if (_s.light >= 1)
    {
        // it turns into a grey orb that keeps riding along
        _s.orb = instance_create_depth(_p.x, _p.y, depth, obj_darkshape_greenblob);
        _s.orb.orb();
        if (instance_exists(ctrl)) ctrl.burst = max(ctrl.burst, 0.5);
    }
}

// the head's purified: it swells and stops, the body ripples away, and the last fish cuts the turn short
if (!dying && light >= 1)
{
    dying = true;
    die_t = 0;
    pop   = 2;
    audio_play_sound(snd_spearappear_choppy, 1, false, 1, 0, 0.65);   // DR's, at 0.65 pitch
    if (instance_exists(ctrl)) { ctrl.dark_count++; ctrl.burst = 1; }
    for (var i = 0; i < array_length(segs); i++) segs[i].auto = (i + 1) * 4;
    if (instance_exists(ctrl))
    {
        if (instance_number(obj_darkshape_fish) == 1) ctrl.t = max(ctrl.t, ctrl.attack_duration - 140);
        else if (ctrl.attack_duration - ctrl.t < 140) ctrl.t -= 140;
    }
}
if (dying)
{
    die_t++;
    if (die_t >= die_time)
    {
        // gone: every orb becomes COURAGE, and the head leaves one too
        for (var i = 0; i < array_length(segs); i++)
        {
            var _s = segs[i];
            if (!instance_exists(_s.orb) && i + 1 < array_length(parts))
                _s.orb = instance_create_depth(parts[i + 1].x, parts[i + 1].y, depth, obj_darkshape_greenblob);
            with (_s.orb) prime();
        }
        instance_create_depth(x, y, depth, obj_darkshape_greenblob);
        instance_destroy();
        exit;
    }
}

// the head and any un-purified piece hurt on touch (orbs don't)
if (!dying && instance_exists(obj_soul) && !obj_soul.invulnerable)
{
    var _hit = point_distance(x, y, _sx, _sy) <= hit_head;
    for (var i = 0; i < array_length(segs) && !_hit; i++)
        if (!instance_exists(segs[i].orb) && i + 1 < array_length(parts) && point_distance(parts[i + 1].x, parts[i + 1].y, _sx, _sy) <= hit_piece) _hit = true;
    if (_hit) scr_soul_take_hit(damage, c_white, c_white);
}