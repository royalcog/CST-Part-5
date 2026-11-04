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

// ---------------------------------------------------------------- from the gang on: everyone sorted by where they stand
if (ysort)
{
    var _ys = [obj_susie, obj_ralsei, obj_queen, obj_mewmew, obj_jevil, obj_spamton];
    for (var i = 0; i < array_length(_ys); i++)
        with (_ys[i]) depth = other.ysort_base - round(scr_get_feet(id).y);
}

// ---------------------------------------------------------------- Jevil teleporting (the fan-out)
if (jevil_tp != undefined)
{
    var _jt = jevil_tp;
    var _j  = instance_find(obj_jevil, 0);
    _jt.t++;
    if (_j == noone) { jevil_tp = undefined; gang_arrived++; }
    else
    {
        var _k = 0;   // 0 = all there, 1 = gone
        if (_jt.t <= tp_time) _k = _jt.t / tp_time;
        else if (_jt.t <= tp_time + tp_gap)
        {
            _k = 1;
            if (!_jt.moved)
            {
                _jt.moved = true;
                with (_j) { image_xscale = 2; image_yscale = 2; }
                scene.set_feet(_j, _jt.x, _jt.y);
                with (_j) { if (variable_instance_exists(id, "start_y")) start_y = y; if (variable_instance_exists(id, "expected_y")) expected_y = y; }
            }
        }
        else
        {
            if (!_jt.back) { _jt.back = true; audio_play_sound(tp_sound, 1, false); }
            _k = max(0, 1 - (_jt.t - tp_time - tp_gap) / tp_time);
        }
        with (_j) { image_xscale = 2 * (1 - 0.9 * _k); image_yscale = 2 * (1 + 0.5 * _k); image_alpha = 1 - _k; }
        if (_jt.back && _k <= 0) { jevil_tp = undefined; gang_arrived++; }
    }
}

// ---------------------------------------------------------------- the stat boost: his HP counting up in his box
if (boost_hp != undefined)
{
    boost_hp.t++;
    var _k = min(1, boost_hp.t / boost_count);
    _k = 1 - (1 - _k) * (1 - _k);
    var _b = ralsei_box();
    if (_b != noone)
    {
        _b.max_hp = round(lerp(boost_hp.max0, boost_to, _k));
        _b.hp     = round(lerp(boost_hp.hp0,  boost_to, _k));
        if (boost_hp.t mod 4 == 0) audio_play_sound(snd_menumove, 1, false, 0.4);
    }
    if (_k >= 1) boost_hp = undefined;
}

// ---------------------------------------------------------------- after the battle
// stay drawn just in front of everyone (the shield over King, the red glow on Ralsei)
if (fb.sa <= 0 && shield != undefined)
{
    var _d = 0;
    with (obj_king)    _d = min(_d, depth);
    with (obj_lancer)  _d = min(_d, depth);
    with (obj_ralsei)  _d = min(_d, depth);
    with (obj_queen)   _d = min(_d, depth);
    with (obj_susie)   _d = min(_d, depth);
    with (obj_mewmew)  _d = min(_d, depth);
    with (obj_jevil)   _d = min(_d, depth);
    with (obj_spamton) _d = min(_d, depth);
    depth = _d - 1;
}
rage_tint  = approach(rage_tint, rage_target, 0.03);
titan_glow = max(0, titan_glow - 0.02);

// Ralsei pushing harder: hit after hit, each faster
if (push != undefined && anim_done(obj_ralsei))
{
    push.t++;
    if (push.t == 1) swap(obj_ralsei, ralsei_idle, 1);
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

// ---------------------------------------------------------------- the standoff: his fire against its laser
if (beam != undefined && beam.phase != "done")
{
    beam.t++;
    switch (beam.phase)
    {
        case "grow":
            beam.fk = min(1, beam.fk + 1 / beam_grow);
            if (beam.t >= beam_laser_delay) beam.lk = min(1, beam.lk + 1 / beam_grow);
            if (beam.fk >= 1 && beam.lk >= 1)
            {
                beam.phase = "clash";
                beam.t = 0;
                audio_play_sound(snd_impact, 1, false);
                scr_camera_shake(4, 16);
            }
        break;

        case "clash":
        {
            var _p = min(1, beam.t / clash_time);
            beam.k = lerp(clash_k0, clash_k1, _p * _p) + sin(beam.t * 0.15) * clash_wobble;   // pushed back toward him
            var _c = beam_clash(), _a = beam_from();
            if (beam.t mod 3 == 0) add_bit(spr_plat_smallfire, _c.x, _c.y, random_range(-4, 4), random_range(-4, 2), random_range(0.8, 1.6), -0.01, irandom_range(12, 22), true);
            if (beam.t mod 5 == 0) { var _r = random(1); add_bit(spr_plat_smallfire, lerp(_a.x, _c.x, _r), lerp(_a.y, _c.y, _r), random_range(-1, 1), random_range(-2, -0.5), random_range(0.5, 1), -0.01, irandom_range(10, 18), true); }
            if (beam.t mod 20 == 0) audio_play_sound(snd_firespell, 1, false, 0.4);
            if (beam.t mod 12 == 0) scr_camera_shake(1, 6);
            if (beam.t >= clash_time) { beam.phase = "tired"; beam.t = 0; }
        }
        break;

        case "tired":   // his beam sputters out, and its laser with it
        {
            var _q = min(1, beam.t / tired_time);
            beam.fw = 1 - _q;
            beam.fa = 1 - _q;
            beam.la = 1 - _q;
            if (beam.t >= tired_time)
            {
                beam.phase = "done";
                if (beam_loop != noone) { audio_stop_sound(beam_loop); beam_loop = noone; }
                rage_target = 0;
                // spent: he puts his defend up and holds it, shaking
                swap(obj_ralsei, spr_ralsei_defend, 0);
                play(obj_ralsei, 0, sprite_get_number(spr_ralsei_defend) - 1, 0.25);
                ralsei_shake = { base: obj_ralsei.x, t: 0 };
            }
        }
        break;
    }
}

// ---------------------------------------------------------------- Ralsei shaking in his defend (until the laser)
if (ralsei_shake != undefined)
{
    ralsei_shake.t++;
    with (obj_ralsei) x = other.ralsei_shake.base + ((other.ralsei_shake.t div other.spent_shake_gap) mod 2 == 0 ? other.spent_shake : -other.spent_shake);
}

// ---------------------------------------------------------------- its laser at him
if (laser != undefined)
{
    laser.t++;
    switch (laser.phase)
    {
        case "charge":
            if (laser.t >= laser_charge)
            {
                laser.phase = "fire";
                laser.t = 0;
                audio_play_sound(snd_chargeshot_fire, 1, false);
                laser_hit();
            }
        break;
        case "fire":
            if (laser.t >= laser_hold) { laser.phase = "fade"; laser.t = 0; }
        break;
        case "fade":
            laser.a = 1 - laser.t / laser_fade;
            if (laser.t >= laser_fade) laser = undefined;
        break;
    }
}

// ---------------------------------------------------------------- Pink's bomb
if (bomb != undefined && !bomb.done)
{
    bomb.t++;
    bomb.rot += 14;
    if (bomb.t >= bomb_time)
    {
        bomb.done = true;
        add_blast(spr_pinkbomb_explosion, bomb.tx, bomb.ty, 0.5, 5);
        add_blast(spr_finisher_explosion, bomb.tx, bomb.ty, 0.3, 0.5);
        audio_play_sound(snd_bomb, 1, false);
        audio_play_sound(snd_explosion, 1, false);
        scr_camera_shake(8, 20);
        var _ti = titan();
        if (_ti != noone) _ti.hurt_red = 1;
    }
}

// ---------------------------------------------------------------- Lancer turns back round once Susie's walked past him
if (lancer_watch)
{
    var _li = instance_find(obj_lancer, 0), _si = instance_find(obj_susie, 0);
    if (_li == noone || _si == noone) lancer_watch = false;
    else if (scr_get_feet(_si).x > scr_get_feet(_li).x)
    {
        lancer_watch = false;
        pose(obj_lancer, spr_lancer_battle_hurt, 2);   // (still shocked)
    }
}