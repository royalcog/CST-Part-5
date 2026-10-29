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

// slithers toward the SOUL, snaking side to side. the more it's lost, the faster and twitchier it gets
var _k = power(panic, pieces_start - pieces);
if (instance_exists(obj_soul))
    heading += clamp(angle_difference(point_direction(x, y, obj_soul.x, obj_soul.y), heading), -turn_rate * _k, turn_rate * _k);
weave += weave_speed * _k;
dir = heading + sin(weave) * weave_amp;
spd = min(spd + 0.03, max_speed * _k);
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

// the light burns it from the tail end (only once the whole body's out)
if (instance_exists(obj_soul))
{
    var _aura = instance_exists(ctrl) ? ctrl.aura_radius : 48;
    var _end  = parts[array_length(parts) - 1];
    if (array_length(parts) == pieces + 1 && point_distance(_end.x, _end.y, obj_soul.x, obj_soul.y) < _aura + 8)
    {
        burn = min(1, burn + ((pieces == 0) ? head_rate : light_rate));
        if (instance_exists(ctrl))
        {
            ctrl.in_light = true;
            if (!irandom(2)) array_push(ctrl.particles, {
                x: _end.x + random_range(-10, 10), y: _end.y + random_range(-10, 10),
                dir: point_direction(obj_soul.x, obj_soul.y, _end.x, _end.y), spd: 0.5 + random(1.5), size: 2
            });
        }
        if (burn >= 1)
        {
            instance_create_depth(_end.x, _end.y, depth, obj_darkshape_greenblob);
            if (instance_exists(ctrl)) { ctrl.dark_count++; ctrl.burst = 1; }
            audio_play_sound(snd_dark_odd, 1, false, 0.3, 0, 1.3);
            if (pieces == 0)
            {
                // the head's gone too: one more pellet for finishing it off
                instance_create_depth(_end.x, _end.y, depth, obj_darkshape_greenblob);
                instance_destroy();
                exit;
            }
            pieces--;
            burn = 0;
        }
    }
    else burn = max(0, burn - 0.005);   // heals slowly out of the light
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