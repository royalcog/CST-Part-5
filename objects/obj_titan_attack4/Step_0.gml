if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
t++;

// ---------------------------------------------------------------- tweens + alarms
for (var i = array_length(tweens) - 1; i >= 0; i--)
{
    var _w = tweens[i];
    if (_w.delay > 0) { _w.delay--; continue; }
    _w.t++;
    var _k = clamp(_w.t / _w.dur, 0, 1);
    variable_instance_set(id, _w.name, lerp(_w.from, _w.to, ease(_k, _w.type, _w.mode)));
    if (_k >= 1) array_delete(tweens, i, 1);
}
for (var a = 0; a < 5; a++)
{
    if (alarms[a] > 0)
    {
        alarms[a]--;
        if (alarms[a] == 0) { alarms[a] = -1; fire_alarm(a); }
    }
}

// ---------------------------------------------------------------- the end: fade out, the box settles back upright
var _all_gone = hands[0].gone && hands[1].gone;
if (_all_gone) gone_t++;
if (!ending && (t >= attack_time || gone_t >= 60))
{
    ending = true;
    alarms = array_create(5, -1);
    tween("image_alpha", image_alpha, 0, end_fade);
    tween("counter_speed", counter_speed, 0, 30);
    tween("angle_counter_speed", angle_counter_speed, 0, 30);
}
if (ending)
{
    var _settle = round(obj_battlebox.box_angle / 360) * 360;
    obj_battlebox.box_angle = lerp(obj_battlebox.box_angle, _settle, 0.15);
    if (abs(obj_battlebox.box_angle - _settle) < 0.5) obj_battlebox.box_angle = _settle;
    if (image_alpha <= 0 && obj_battlebox.box_angle == _settle && array_length(bullets) == 0)
    {
        obj_battlebox.box_angle = 0;
        instance_destroy();
        exit;
    }
}

// ---------------------------------------------------------------- the SOUL's light (grows in, like the Titan Spawn's)
var _goal = variable_global_exists("soul_glow_radius") ? global.soul_glow_radius : 48;
aura_radius = scr_approach(aura_radius, _goal, abs(_goal - aura_radius) * 0.0513);

// ---------------------------------------------------------------- the hands (and the box turning with them)
counter       += counter_speed;
angle_counter += angle_counter_speed;
if (!_all_gone) turn += angle_counter_speed * turn_mult;
hand_direction = turn + cos(angle_counter) * 4;
if (!ending) obj_battlebox.box_angle = turn;

var _c   = scr_box_center();
var _chx = _c.x;
var _chy = _c.y + sin(counter) * 40 - 20;
var _armed = t >= 60;   // (Deltarune: they can hurt you 30 frames in)
var _stump_gap = 80 + difficulty * 4;

for (var h = 0; h < 2; h++)
{
    var _h = hands[h];
    if (_h.gone) continue;

    if (_h.broken < 4)
    {
        var _dir = hand_direction + h * 180;
        var _sx = 0, _sy = 0;
        if (alarms[2] > 0) { _sx = choose(-2, 0, 2); _sy = choose(-2, 0, 2); }   // shaking before the slam
        _h.x   = _chx + lengthdir_x(hand_distance, _dir);
        _h.y   = _chy + lengthdir_y(hand_distance, _dir);
        _h.ang = point_direction(_h.x, _h.y, _chx, _chy);
        _h.x  += lengthdir_x(sin(wave_counter) * 20, _dir + 90) + _sx;
        _h.y  += lengthdir_y(sin(wave_counter) * 20, _dir + 90) + _sy;

        for (var i = 0; i < 4; i++)
        {
            var _f = _h.fingers[i];
            if (_f.alive)
            {
                _f.x   = _h.x + lengthdir_x(_f.fwd, _h.ang) + lengthdir_x(_f.side, _h.ang + 90);
                _f.y   = _h.y + lengthdir_y(_f.fwd, _h.ang) + lengthdir_y(_f.side, _h.ang + 90);
                _f.ang = _h.ang;
            }
            else if (!ending && (alarms[0] > 0 || alarms[4] > 0) && ((t + i * 20) mod _stump_gap) == 0) stump_shot(_h, _f);
        }

        // afterimages as they slam
        if (alarms[3] > 20 && t mod 6 == 0)
            array_push(afters, { x: _h.x, y: _h.y, xs: _h.xs, ys: _h.ys, ang: _h.ang, a: 0.6 });

        if (_armed && !ending && touches(spr_titan_battle_hand, 0, _h.x, _h.y, _h.xs, _h.ys, _h.ang))
            scr_soul_take_hit(damage, c_white, c_white);
    }
    else
    {
        // overloading: slides back out, shaking, going white, little explosions... then it blows
        _h.ov_t++;
        var _k = min(1, _h.ov_t / 60);
        var _e = 1 - power(1 - _k, 4);
        _h.x = _h.bx + lengthdir_x(80 * _e, _h.out_dir) + choose(-1, 0, 1);
        _h.y = _h.by + lengthdir_y(80 * _e, _h.out_dir) + choose(-1, 0, 1);
        if (irandom(3) == 0)
            add_boom(_h.x + irandom_range(-80, 80), _h.y + irandom_range(-60, 60), 90, 4, irandom(4), 16);
        if (_h.ov_t >= 60)
        {
            audio_play_sound(snd_explosion, 1, false);
            scr_camera_shake(6, 16);
            for (var bb = 0; bb < 8; bb++) add_boom(_h.x + irandom_range(-40, 40), _h.y + irandom_range(-30, 30), irandom(360), 8, bb, 32);
            add_shock(_h.x, _h.y, 0.5,   1,   0.5);
            add_shock(_h.x, _h.y, 0.375, 1.5, 0.75);
            add_shock(_h.x, _h.y, 0.25,  2,   1);
            _h.gone = true;
        }
    }
}

// ---------------------------------------------------------------- the fingers
var _nf = sprite_get_number(finger_sprite);
for (var h = 0; h < 2; h++)
{
    var _h = hands[h];
    if (_h.gone) continue;
    for (var i = 0; i < 4; i++)
    {
        var _f = _h.fingers[i];
        if (!_f.alive) continue;

        // curling (once through, then back open)
        if (_f.curl_in > 0) { _f.curl_in--; if (_f.curl_in == 0) _f.ispd = curl_speed; }
        _f.img += _f.ispd;
        if (_f.img >= _nf) { _f.img = 0; _f.ispd = 0; }

        // its 3 bullets
        if (_f.shot_in > 0 && !ending)
        {
            _f.shot_in--;
            if (_f.shot_in == 0)
            {
                finger_shot(_h, _f);
                _f.shots_left--;
                if (_f.shots_left > 0) _f.shot_in = wibbly_cooldown;
            }
        }

        if (_armed && !ending && touches(spr_titan_battle_finger_dark_mask, floor(_f.img), _f.x, _f.y, _f.xs, _f.ys, _f.ang))
            scr_soul_take_hit(damage, c_white, c_white);

        // the SOUL's light on its weak spot
        if (instance_exists(obj_soul))
        {
            var _w = weak_pos(_f);
            if (point_distance(_w.x, _w.y, obj_soul.x, obj_soul.y) < aura_radius + 8)
            {
                _f.light = scr_approach(_f.light, 1, light_up);
                if (irandom(5) == 0)
                    array_push(specks, { x: _w.x + random_range(-12, 12), y: _w.y + random_range(-12, 12),
                                         dir: point_direction(obj_soul.x, obj_soul.y, _w.x, _w.y), spd: (1 + random(3)) / 2, size: 2 });
            }
            else _f.light = scr_approach(_f.light, 0, light_down);
        }
        if (_f.light >= 1) break_finger(_h, _f);
    }
}

// ---------------------------------------------------------------- the wibbly bullets
for (var i = array_length(bullets) - 1; i >= 0; i--)
{
    var _b = bullets[i];
    _b.t++;
    _b.spd = lerp(_b.sf, _b.st, min(1, _b.t / 120));
    _b.s   = 2 * (1 - power(1 - min(1, _b.t / 30), 2));
    _b.x  += lengthdir_x(_b.spd, _b.dir);
    _b.y  += lengthdir_y(_b.spd, _b.dir);
    _b.f  += 0.25;
    if (ending) _b.a -= 0.05;

    var _dead = (_b.a <= 0) || point_distance(_b.x, _b.y, _c.x, _c.y) > 700;
    // the other hand swallows it
    var _o = hands[1 - _b.owner];
    if (!_o.gone && point_distance(_b.x, _b.y, _o.x, _o.y) < hand_kill_r) _dead = true;
    if (!_dead && !ending && _b.s > 0.5
     && touches(spr_wibblywobbly_dark_bullet, floor(_b.f), _b.x, _b.y, _b.s, _b.s, 0))
        scr_soul_take_hit(bullet_damage, c_white, c_white);
    if (_dead) array_delete(bullets, i, 1);
}

// ---------------------------------------------------------------- explosions, specks, afterimages
for (var i = array_length(booms) - 1; i >= 0; i--)
{
    var _m = booms[i];
    _m.t++;
    _m.f += _m.fspd;
    var _sp = lerp(_m.spd0, _m.spd0 / 8, min(1, _m.t / _m.spd_time));
    _m.x += lengthdir_x(_sp, _m.dir);
    _m.y += lengthdir_y(_sp, _m.dir);
    if (_m.f >= sprite_get_number(_m.spr)) array_delete(booms, i, 1);
}
for (var i = array_length(specks) - 1; i >= 0; i--)
{
    var _p = specks[i];
    _p.x += lengthdir_x(_p.spd, _p.dir);
    _p.y += lengthdir_y(_p.spd, _p.dir);
    _p.size -= 0.1;
    if (_p.size <= 0) array_delete(specks, i, 1);
}
for (var i = array_length(afters) - 1; i >= 0; i--)
{
    afters[i].a -= 0.05;
    if (afters[i].a <= 0) array_delete(afters, i, 1);
}