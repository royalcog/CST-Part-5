t++;

// ---------------------------------------------------------------- the script
if (step_i < array_length(steps))
{
    var _st = steps[step_i];
    if (!step_on)
    {
        step_on = true;
        step_t  = 0;
        if (_st.run != undefined) _st.run();
        if (!instance_exists(id)) exit;
    }
    var _ok = (_st.until == undefined) || _st.until();
    if (_ok)
    {
        step_t++;
        if (step_t > _st.wait) { step_i++; step_on = false; }
    }
}

// ---------------------------------------------------------------- frame-by-frame animations
for (var k = 0; k < array_length(anims); k++)
{
    var _a = anims[k];
    if (_a.done || !instance_exists(_a.o)) continue;
    _a.f += _a.spd;
    if ((_a.spd > 0 && _a.f >= _a.to) || (_a.spd < 0 && _a.f <= _a.to)) { _a.f = _a.to; _a.done = true; }
    _a.o.image_index = floor(_a.f);
    _a.o.image_speed = 0;
    if (_a.ev != undefined && floor(_a.f) == _a.ev_frame) { var _e = _a.ev; _a.ev = undefined; _e(); }
}

// ---------------------------------------------------------------- King
switch (king_mode)
{
    case "flick": if (anim_done(obj_king)) king_idle(); break;
    case "hurt":  king_t--; if (king_t <= 0) king_idle(); break;
}
if (king_shake.on && instance_exists(obj_king) && t mod 2 == 0)
    obj_king.x = king_shake.base + choose(-1, 1) * round(king_shake.amt);

// ---------------------------------------------------------------- the flashback's fades
fb.a     = approach(fb.a,  fb.target,  1 / ((fb.target > fb.a) ? fb_black_time : fb_out_time));
fb.sa    = approach(fb.sa, fb.starget, 1 / fb_sil_time);
fb.flash = max(0, fb.flash - 0.03);

// ---------------------------------------------------------------- the wheel of fire
if (wheel != undefined && !wheel.gone)
{
    wheel.rot += wheel_spin;
    if (!wheel.embrace) wheel.k = min(1, wheel.k + 1 / wheel_grow);
    else
    {
        wheel.ek = min(1, wheel.ek + 1 / embrace_time);
        fb.red = wheel.ek;
        if (wheel.ek >= 1) wheel.gone = true;
    }
}

// ---------------------------------------------------------------- the fireballs, faster and faster
if (barrage != undefined && !barrage.done)
{
    barrage.t++;
    if (barrage.fired < shot_count && barrage.t >= barrage.next)
    {
        var _n = barrage.fired;
        var _chance = (_n < always_block) ? 1 : lerp(1, block_min, (_n - always_block) / max(1, shot_count - 1 - always_block));
        throw_fire(barrage.spd, random(1) < _chance, false, barrage.gap);
        barrage.fired++;
        barrage.spd  = min(shot_speed_max, barrage.spd * shot_speed_mult);
        barrage.gap  = max(shot_gap_min, barrage.gap * shot_gap_mult);
        barrage.next = barrage.t + barrage.gap;
    }
    if (barrage.fired >= shot_count && barrage.pending == 0 && array_length(shots) == 0 && array_length(kspades) == 0) barrage.done = true;
}

for (var i = array_length(shots) - 1; i >= 0; i--)
{
    var _s = shots[i];
    _s.f += 0.3;
    _s.x += lengthdir_x(_s.spd, _s.dir);
    _s.y += lengthdir_y(_s.spd, _s.dir);

    // the last one: Queen's shield
    if (_s.shielded && shield != undefined && _s.x >= shield_face())
    {
        puff(_s.x, _s.y, 10);
        audio_play_sound(snd_impact, 1, false);
        shield.flash = 1;
        array_delete(shots, i, 1);
        last_hit = true;
        pose(obj_ralsei, spr_ralsei_shocked, 2);
        continue;
    }

    var _k  = mid(obj_king);
    var _dk = point_distance(_s.x, _s.y, _k.x, _k.y);
    // close enough: he flicks a spade at it
    if (_s.blocked && !_s.flicked && _dk <= block_reach)
    {
        _s.flicked = true;
        king_flick();
        array_push(kspades, { x: _k.x - 20, y: _k.y, shot: _s, rot: random(360) });
        audio_play_sound(snd_criticalswing, 1, false, 0.6);
    }
    if (_dk <= _s.spd + 12)
    {
        puff(_s.x, _s.y, 8);
        if (!_s.blocked)
        {
            audio_play_sound(snd_impact, 1, false, 0.7);
            king_hurt(king_hurt_time);
            king_damage(max(1, round(king_hp * shot_hit_frac)));
        }
        array_delete(shots, i, 1);
    }
}

// King's spades, straight at the fireball they're for
for (var i = array_length(kspades) - 1; i >= 0; i--)
{
    var _p = kspades[i];
    _p.rot += 25;
    var _si = -1;
    for (var j = 0; j < array_length(shots); j++) if (shots[j] == _p.shot) { _si = j; break; }
    if (_si == -1) { array_delete(kspades, i, 1); continue; }
    var _s = shots[_si];
    if (point_distance(_p.x, _p.y, _s.x, _s.y) <= kspade_speed + _s.spd)
    {
        puff(_s.x, _s.y, 6);
        spade_bits(_s.x, _s.y);
        audio_play_sound(snd_impact, 1, false, 0.5);
        array_delete(shots, _si, 1);
        array_delete(kspades, i, 1);
        continue;
    }
    var _ang = point_direction(_p.x, _p.y, _s.x, _s.y);
    _p.x += lengthdir_x(kspade_speed, _ang);
    _p.y += lengthdir_y(kspade_speed, _ang);
}

// ---------------------------------------------------------------- the inferno
if (inferno != undefined)
{
    inferno.t++;
    if (inferno.t <= inferno_time)
    {
        var _k = mid(obj_king), _f = feet(obj_king);
        repeat (inferno_rate)
            add_bit(spr_plat_fire, _k.x + random_range(-inferno_w, inferno_w), _f.y - random(30), random_range(-0.6, 0.6),
                    random_range(-4.5, -1.5), random_range(0.8, 1.4), 0.015, irandom_range(30, 55), true);
        if (inferno.t mod 20 == 0) audio_play_sound(snd_firespell, 1, false, 0.5);
    }
    if (inferno.t == inferno_hit_at) king_damage(king_hp - 1);
    if (inferno.t == inferno_time) king_shake.amt = 1;   // still trembling
}

// ---------------------------------------------------------------- bits
for (var i = array_length(bits) - 1; i >= 0; i--)
{
    var _b = bits[i];
    _b.t++;
    _b.vy  += _b.g;
    _b.x   += _b.vx;
    _b.y   += _b.vy;
    _b.s   += _b.ds;
    _b.rot += _b.vr;
    if (_b.t >= _b.life) array_delete(bits, i, 1);
}

// ---------------------------------------------------------------- Queen's shield
if (shield != undefined)
{
    shield.t++;
    shield.bob  += shield_bob_speed;
    shield.flash = max(0, shield.flash - 0.15);
}

// ---------------------------------------------------------------- after the battle
// stay drawn just in front of everyone (the shield over King, the red glow on Ralsei)
if (fb.sa <= 0 && shield != undefined)
{
    var _d = 0;
    with (obj_king)   _d = min(_d, depth);
    with (obj_lancer) _d = min(_d, depth);
    with (obj_ralsei) _d = min(_d, depth);
    with (obj_queen)  _d = min(_d, depth);
    depth = _d - 1;
}
rage_tint  = approach(rage_tint, rage_target, 0.03);
titan_glow = max(0, titan_glow - 0.02);

// Ralsei pushing harder: hit after hit, each faster
if (push != undefined && anim_done(obj_ralsei))
{
    push.t++;
    if (push.t == 1) swap(obj_ralsei, spr_ralsei_battle_idle, 0.15);
    if (push.left <= 0)
    {
        if (push.t >= push_end_wait) push = undefined;
    }
    else if (push.t >= push.gap)
    {
        ralsei_hit(push.spd);
        push.left--;
        push.t   = 0;
        push.spd = push.spd * push_speed_mult;
        push.gap = max(push_gap_min, push.gap * 0.7);
    }
}

// the Titan hammering Queen's shield
if (pressure != undefined)
{
    pressure.t++;
    if (pressure.left > 0 && pressure.t >= pressure_gap)
    {
        pressure.t = 0;
        pressure.left--;
        with (obj_queen_shield)
        {
            var _cx = x + sprite_get_width(spr_queen_shield) * scale / 2;
            var _cy = y - sprite_get_height(spr_queen_shield) * scale / 2;
            other.add_blast(spr_titan_shockwave_bullet_explosion, _cx, _cy, 0.3, 0.6);
            hit(other.pressure_dmg);
        }
        audio_play_sound(snd_impact, 1, false);
        scr_camera_shake(5, 12);
        scene.slide(obj_queen, -pressure_push, 0, 10, 0);
    }
    if (pressure.left <= 0 && pressure.t >= pressure_gap) pressure = undefined;
}

// explosions
for (var i = array_length(blasts) - 1; i >= 0; i--)
{
    blasts[i].f += blasts[i].fspd;
    if (blasts[i].f >= sprite_get_number(blasts[i].spr)) array_delete(blasts, i, 1);
}