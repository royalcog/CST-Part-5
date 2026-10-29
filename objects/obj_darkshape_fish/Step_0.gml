if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    image_alpha -= 0.1;
    if (image_alpha <= 0) instance_destroy();
    exit;
}

t++;
image_alpha = min(1, image_alpha + 0.05);

// slithers toward the SOUL, snaking side to side (slowed while it's lit)
if (instance_exists(obj_soul))
    heading += clamp(angle_difference(point_direction(x, y, obj_soul.x, obj_soul.y), heading), -turn_rate, turn_rate);
weave += weave_speed;
dir = heading + sin(weave) * weave_amp;
spd = scr_approach(spd, max_speed * (lit ? light_slow : 1), 0.03);
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);

// the body follows the exact path the head took
array_insert(hist, 0, { x: x, y: y });
if (array_length(hist) > 600) array_resize(hist, 600);
parts = [{ x: x, y: y, a: dir }];
var _need = spacing, _acc = 0, _px = x, _py = y;
for (var h = 1; h < array_length(hist) && array_length(parts) <= pieces; h++)
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

// the light purifies the whole fish: faster the more of it's in the light
lit = false;
if (instance_exists(obj_soul))
{
    var _aura = instance_exists(ctrl) ? ctrl.aura_radius : 48;
    var _n_lit = 0;
    for (var i = 0; i < array_length(parts); i++)
    {
        var _p = parts[i];
        if (point_distance(_p.x, _p.y, obj_soul.x, obj_soul.y) < _aura + 8)
        {
            _n_lit++;
            if (instance_exists(ctrl) && !irandom(5)) array_push(ctrl.particles, {
                x: _p.x + random_range(-10, 10), y: _p.y + random_range(-10, 10),
                dir: point_direction(obj_soul.x, obj_soul.y, _p.x, _p.y), spd: 0.5 + random(1.5), size: 2
            });
        }
    }
    if (_n_lit > 0)
    {
        lit = true;
        light = min(1, light + light_rate * (1 + light_extra * (_n_lit - 1)));
        if (instance_exists(ctrl)) ctrl.in_light = true;
    }
    else light = max(0, light - light_recover);

    if (light >= 1)
    {
        // purified: COURAGE spread along its body
        for (var k = 0; k < pellets; k++)
        {
            var _p = parts[floor(k * (array_length(parts) - 1) / max(1, pellets - 1))];
            instance_create_depth(_p.x, _p.y, depth, obj_darkshape_greenblob);
        }
        if (instance_exists(ctrl)) { ctrl.dark_count++; ctrl.burst = 1; }
        audio_play_sound(snd_dark_odd, 1, false, 0.4, 0, 1.3);
        instance_destroy();
        exit;
    }
}

// any piece touching the SOUL hurts (it doesn't vanish: the SOUL's flash stops repeat hits)
if (instance_exists(obj_soul) && !obj_soul.invulnerable)
{
    for (var i = 0; i < array_length(parts); i++)
    {
        if (point_distance(parts[i].x, parts[i].y, obj_soul.x, obj_soul.y) <= ((i == 0) ? hit_head : hit_piece))
        {
            scr_soul_take_hit(damage, c_white, c_white);
            break;
        }
    }
}