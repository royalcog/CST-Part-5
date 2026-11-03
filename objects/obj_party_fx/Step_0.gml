t++;
var _o = owner;

switch (kind)
{
    // ---------------------------------------------------------------- Pink: up into the air, and throws it
    case "bomb":
        // her throw plays once and holds its last frame
        if (instance_exists(_o) && _o.sprite_index == spr_pink_throw_bomb_corrupted && _o.image_index >= sprite_get_number(_o.sprite_index) - 1)
        {
            _o.image_index = sprite_get_number(_o.sprite_index) - 1;
            _o.image_speed = 0;
        }
        switch (state)
        {
            case "wait":
                if (!instance_exists(_o) || floor(_o.image_index) >= release_frame || t >= 90)
                {
                    var _s = instance_exists(_o) ? sign(_o.image_xscale) : 1;
                    sx = instance_exists(_o) ? _o.x + bomb_hand.x * _s : 0;
                    sy = instance_exists(_o) ? _o.y + bomb_hand.y : 0;
                    var _a = aim();
                    tx = _a.x; ty = _a.y;
                    audio_play_sound(snd_swing, 1, false);
                    state = "fly"; t = 0;
                }
            break;
            case "fly":
            {
                var _k = min(1, t / bomb_time);
                px = lerp(sx, tx, _k);
                py = lerp(sy, ty, _k) - sin(_k * pi) * bomb_arc;
                rot += bomb_spin;
                if (_k >= 1)
                {
                    hit = true;
                    add_boom(spr_pinkbomb_explosion, tx, ty, 0.5, boom_scale);
                    audio_play_sound(snd_bomb, 1, false);
                    scr_camera_shake(4, 10);
                    state = "boom"; t = 0;
                }
            }
            break;
        }
    break;

    // ---------------------------------------------------------------- Jevil: a spade appears in front of him, then flies
    case "spade":
        switch (state)
        {
            case "wait":
            {
                var _s = instance_exists(_o) ? sign(_o.image_xscale) : 1;
                px = instance_exists(_o) ? _o.x + spade_at.x * _s : 0;
                py = instance_exists(_o) ? _o.y + spade_at.y : 0;
                audio_play_sound(snd_spear_appear, 1, false);
                state = "grow"; t = 0;
            }
            break;
            case "grow":
                scale = spade_scale * (1 - power(1 - min(1, t / spade_grow), 3));
                rot += 24;
                if (t >= spade_grow) { state = "hover"; t = 0; }
            break;
            case "hover":
                rot += 36;
                if (t >= spade_hover)
                {
                    var _a = aim();
                    tx = _a.x; ty = _a.y;
                    audio_play_sound(snd_criticalswing, 1, false);
                    state = "shoot"; t = 0;
                }
            break;
            case "shoot":
            {
                rot += 36;
                if (point_distance(px, py, tx, ty) <= spade_speed)
                {
                    hit = true;
                    audio_play_sound(snd_impact, 1, false);
                    repeat (6) array_push(bits, { x: tx, y: ty, vx: random_range(-4, 4), vy: random_range(-5, -1), rot: random(360), vr: random_range(-15, 15), t: 0 });
                    state = "boom"; t = 0;
                }
                else
                {
                    var _d = point_direction(px, py, tx, ty);
                    px += lengthdir_x(spade_speed, _d);
                    py += lengthdir_y(spade_speed, _d);
                }
            }
            break;
        }
    break;

    // ---------------------------------------------------------------- Spamton: pipis drop on its face from above
    case "pipis":
        switch (state)
        {
            case "wait":
            {
                var _a = aim();
                tx = _a.x; ty = _a.y + face_dy;
                audio_play_sound(snd_bombfall, 1, false);
                for (var i = 0; i < pipis_n; i++)
                    array_push(pipis, { x: tx + random_range(-30, 30), y: ty - pipis_from - i * 40, vy: 0, delay: i * pipis_gap, rot: random(360), done: false });
                state = "drop"; t = 0;
            }
            break;
            case "drop":
            {
                var _left = 0;
                for (var i = 0; i < array_length(pipis); i++)
                {
                    var _p = pipis[i];
                    if (_p.done) continue;
                    _left++;
                    if (_p.delay > 0) { _p.delay--; continue; }
                    _p.vy  += pipis_grav;
                    _p.y   += _p.vy;
                    _p.rot += 10;
                    if (_p.y >= ty)
                    {
                        _p.done = true;
                        add_boom(spr_pinkbomb_explosion, _p.x, ty, 0.5, boom_scale * 0.7);
                        audio_play_sound(snd_explosion, 1, false, 0.5);
                        scr_camera_shake(2, 6);
                    }
                }
                if (_left == 0) { hit = true; state = "boom"; t = 0; }
            }
            break;
        }
    break;
}

// explosions, chunks
for (var i = array_length(booms) - 1; i >= 0; i--)
{
    booms[i].f += booms[i].fspd;
    if (booms[i].f >= sprite_get_number(booms[i].spr)) array_delete(booms, i, 1);
}
for (var i = array_length(bits) - 1; i >= 0; i--)
{
    var _b = bits[i];
    _b.t++; _b.vy += 0.3; _b.x += _b.vx; _b.y += _b.vy; _b.rot += _b.vr;
    if (_b.t >= 30) array_delete(bits, i, 1);
}
if (state == "boom" && array_length(booms) == 0 && array_length(bits) == 0) instance_destroy();