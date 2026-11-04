t++;

// ---------------------------------------------------------------- the screen shake (its own: everything's drawn from the camera)
if (shake.t > 0) { shake.t--; shake.x = irandom_range(-shake.amt, shake.amt); shake.y = irandom_range(-shake.amt, shake.amt); }
else { shake.amt = 0; shake.x = 0; shake.y = 0; }
white.a = approach(white.a, white.to, white.spd);

// ---------------------------------------------------------------- the intro
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
if (phase == "intro")
{
    // the platforms, one after another
    if (pillar_t >= 0)
    {
        pillar_t++;
        for (var i = 0; i < pillars; i++)
        {
            var _was = pillar_k[i];
            pillar_k[i] = clamp((pillar_t - i * pillar_gap) / pillar_rise, 0, 1);
            if (_was <= 0 && pillar_k[i] > 0) { audio_play_sound(snd_petrify_gravel, 1, false, 0.6); scr_camera_shake(1, 20); }
        }
        bank_k = min(1, bank_k + 1 / bank_rise_time);
    }
    // the Titan, sinking
    if (sink != undefined && sink.t < sink_time)
    {
        sink.t++;
        var _k = sink.t / sink_time;
        with (obj_titan_reveal) y = other.sink.y0 + other.sink_dist * _k * _k;
    }
    // the feather, rising over her fist
    if (feather.on) feather.t++;
    exit;
}

// ---------------------------------------------------------------- the run
var _jp = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_up);
var _jh = keyboard_check(ord("Z")) || keyboard_check(vk_up);
var _xp = keyboard_check_pressed(ord("X"));
var _running = (phase == "run") || (fin.st == "sink") || (fin.st == "stop");
if (!_running) { _jp = false; _jh = false; _xp = false; }
if (white.a > 0.5) { _jp = false; _xp = false; }   // (not while it's still white)

// how fast: full speed, until the last platform's edge is coming up
if (final_made)
{
    var _left = final_edge - dist - edge_sx;
    spd = min(run_speed, sqrt(max(0, 2 * stop_decel * _left)));
    if (spd < 0.05) spd = 0;
}
dist += spd;
gen();

// Susie, and Ralsei (dodging on his own)
move_member(susie, _jp, _jh);
var _rj = _running && white.a <= 0.5 && ralsei_jump();
move_member(ralsei, _rj, false);
if (_xp)
{
    // X: whoever the Titan Spawn's coming for (or Susie)
    var _who = (spawn != undefined && spawn.st == "ring") ? spawn.who : "Susie";
    attack((_who == "Susie") ? susie : ralsei);
}

// their attacks: the swing, then the shot
var _ms = [susie, ralsei];
for (var i = 0; i < 2; i++)
{
    var _m = _ms[i];
    if (_m.atk == undefined) continue;
    var _spr = atk_sprite(_m);
    _m.atk.t += spd_of(_spr) * 2;
    if (!_m.atk.fired && _m.atk.t >= atk_fire(_m))
    {
        _m.atk.fired = true;
        var _f  = atk_from(_m);
        var _sx = _m.sx + _f.x * 2, _sy = _m.y + _f.y * 2;
        var _tx = (spawn != undefined) ? spawn.x : _sx + 300, _ty = (spawn != undefined) ? spawn.y : _sy;
        if (!_m.atk.hit) { _tx += 40; _ty -= 60; }   // (too early: it goes wide)
        array_push(shots, { x: _sx, y: _sy, x0: _sx, y0: _sy, tx: _tx, ty: _ty, t: 0, time: 14,
                            spr: (_m.who == "Susie") ? spr_rudebuster_projectile : spr_plat_fireball, kill: _m.atk.hit });
        audio_play_sound((_m.who == "Susie") ? snd_boost : snd_smallswing, 1, false);
        if (_m.atk.hit && spawn != undefined) spawn.st = "shot";   // (it waits for the shot to land)
    }
    if (_m.atk.t >= sprite_get_number(_spr)) _m.atk = undefined;
}
for (var i = array_length(shots) - 1; i >= 0; i--)
{
    var _s = shots[i];
    _s.t++;
    var _k = _s.t / _s.time;
    _s.x = lerp(_s.x0, _s.tx, _k); _s.y = lerp(_s.y0, _s.ty, _k);
    if (_s.t >= _s.time)
    {
        if (_s.kill && spawn != undefined)
        {
            spawn.st = "dead"; spawn.dead = 0;
            audio_play_sound(snd_damagetaken, 1, false);
            array_push(pops, { x: _s.x, y: _s.y, t: 0, spr: spr_titan_shockwave_bullet_explosion, s: 0.2, txt: "", col: c_white });
        }
        array_delete(shots, i, 1);
    }
}

// the Titan, far off: up out of the clouds, and (at the end) back down
if (phase == "run")
{
    run_t++;
    if (run_t >= titan_rise_at) titan_far_k = min(1, titan_far_k + 1 / titan_rise_time);
    // what it throws
    if (run_t >= next_hazard && run_t < run_len)
    {
        if (spawn == undefined && random(1) < spawn_chance) send_spawn();
        else
        {
            throw_orb();
            if (random(1) < pair_chance) next_hazard = run_t + pair_gap;   // (another behind it, a jump apart)
        }
        if (next_hazard <= run_t) next_hazard = run_t + round(lerp(hazard_gap[0], hazard_gap[1], run_t / run_len));
    }
    // Queen's chair
    if (run_t == queen_at) { queen_k = 0; audio_play_sound(snd_motor_ghost, 1, false, 0.7); }
    if (queen_k >= 0) queen_k = min(1, queen_k + 1 / queen_time);
    // the end: once nothing's left flying at them
    if (run_t >= run_len && array_length(orbs) == 0 && spawn == undefined)
    {
        phase = "final";
        fin = { st: "sink", t: 0 };
        audio_play_sound(snd_titan_wingshut, 1, false);
    }
}

// the fish: from its star down onto the path ahead, then swimming along it at them
for (var i = array_length(orbs) - 1; i >= 0; i--)
{
    var _o = orbs[i];
    if (!_o.landed)
    {
        _o.k += 1 / orb_time;
        if (_o.k >= 1) { _o.landed = true; audio_play_sound(snd_impact, 1, false, 0.5); }
    }
    else _o.wx -= fish_swim;
    var _ox = _o.wx - dist;
    if (_o.landed)
    {
        // any piece of it touching either of them
        for (var j = 0; j < 2 && !_o.done; j++)
        {
            var _m = _ms[j];
            var _l = _m.sx - hw, _r = _m.sx + hw, _tp = _m.y - body_h, _bt = _m.y;
            for (var k = 0; k <= 5; k++)
            {
                var _pc = fish_piece(k, _ox, _o.y, 180, fish_scale, t * 0.22);
                if (point_distance(_pc.x, _pc.y, clamp(_pc.x, _l, _r), clamp(_pc.y, _tp, _bt)) < fish_hit_r * fish_scale)
                {
                    hurt(_m, orb_dmg);
                    array_push(pops, { x: _pc.x, y: _pc.y, t: 0, spr: spr_titan_shockwave_bullet_explosion, s: 0.15, txt: "", col: c_white });
                    _o.done = true;
                    break;
                }
            }
        }
    }
    if (_o.done || _ox < -200) array_delete(orbs, i, 1);
}

// the Titan Spawn: flies in, the ring closes on it, then it's hit (or it hits)
if (spawn != undefined)
{
    var _p = spawn;
    _p.t++;
    switch (_p.st)
    {
        case "fly":
        {
            var _k = min(1, _p.t / spawn_fly);
            var _e = 1 - (1 - _k) * (1 - _k);
            _p.x = lerp(_p.x0, spawn_hover.x, _e); _p.y = lerp(_p.y0, spawn_hover.y, _e) - sin(_k * pi) * 40;
            _p.s = lerp(0.2, 1, _e);
            if (_k >= 1) { _p.st = "ring"; _p.t = 0; audio_play_sound(snd_eye_telegraph, 1, false); }
        }
        break;
        case "ring":
            _p.y = spawn_hover.y + sin(t / 10) * 6;
            if (_p.t > ring_time + ring_window) { _p.st = "lunge"; _p.t = 0; _p.x0 = _p.x; _p.y0 = _p.y; }
        break;
        case "lunge":
        {
            var _m = (_p.who == "Susie") ? susie : ralsei;
            var _k = _p.t / spawn_lunge;
            _p.x = lerp(_p.x0, _m.sx, _k); _p.y = lerp(_p.y0, _m.y - body_h / 2, _k);
            if (_k >= 1)
            {
                hurt(_m, spawn_dmg);
                array_push(pops, { x: _p.x, y: _p.y, t: 0, spr: spr_titan_shockwave_bullet_explosion, s: 0.2, txt: "", col: c_white });
                spawn = undefined;
            }
        }
        break;
        case "shot": break;   // (a shot's on its way)
        case "dead":
            _p.dead++;
            if (_p.dead >= 30) spawn = undefined;
        break;
    }
}
for (var i = array_length(pops) - 1; i >= 0; i--) { pops[i].t++; if (pops[i].t >= 40) array_delete(pops, i, 1); }

// ---------------------------------------------------------------- the end
if (phase != "final") exit;
fin.t++;
switch (fin.st)
{
    case "sink":   // the far Titan sinks away; the last platform's coming
        titan_far_k = max(0, 1 - fin.t / final_sink);
        final_plan = true;
        if (final_made && fin.t >= final_sink) { fin.st = "stop"; fin.t = 0; }
    break;

    case "stop":   // they slow to a stop near its edge
        if (spd <= 0 && susie.grounded && ralsei.grounded)
        {
            fin.st = "rise"; fin.t = 0;
            audio_play_sound(snd_titan_wingshut, 1, false);
            audio_play_sound(snd_petrify_gravel_thunder, 1, false);
            do_shake(6, near_rise);
        }
    break;

    case "rise":   // it comes up at the edge
    {
        var _k = min(1, fin.t / near_rise);
        titan_near_k = 1 - (1 - _k) * (1 - _k);
        if (_k >= 1) { fin.st = "charge"; fin.t = 0; audio_play_sound(snd_titan_petrify_blast, 1, false); }
    }
    break;

    case "charge":   // its star glows; they put their defends up (Ralsei steps in right behind her)
        if (fin.t == 1) { susie.pose = "defend"; ralsei.pose = "defend"; susie.fx = 0; ralsei.fx = 0; }
        ralsei.sx = approach(ralsei.sx, susie.sx - defend_gap, 2);
        if (fin.t >= laser_charge)
        {
            fin.st = "laser"; fin.t = 0;
            audio_play_sound(snd_chargeshot_fire, 1, false);
            do_shake(5, 30);
        }
    break;

    case "laser":   // it fires; the others come in behind them, one by one
    {
        if (fin.t mod 10 == 0) do_shake(2, 8);
        for (var i = 0; i < array_length(allies); i++)
        {
            if (fin.t == 30 + i * allies_gap) { audio_play_sound(snd_appear, 1, false); }
            if (fin.t >= 30 + i * allies_gap) ally_k[i] = min(1, ally_k[i] + 1 / 20);
        }
        if (fin.t >= 30 + array_length(allies) * allies_gap + 30) { fin.st = "press"; fin.t = 0; audio_play_sound(snd_power, 1, false); }
    }
    break;

    case "press":   // the PRESS box: mash Z
    {
        box_k = min(1, box_k + 1 / box_in);
        if (fin.t mod 10 == 0) do_shake(2, 8);
        if (box_k >= 1 && keyboard_check_pressed(ord("Z")))
        {
            press_on = true;
            press_k = min(1, press_k + press_add);
            var _blocks = [snd_soundbattle_upblock, snd_soundbattle_leftblock, snd_soundbattle_rightblock, snd_soundbattle_downblock];
            audio_play_sound(_blocks[irandom(3)], 1, false, 0.7);
            susie.fx = 1; ralsei.fx = 1;
        }
        else if (press_on) press_k = max(0, press_k - press_decay);
        susie.fx = max(0, susie.fx - 0.1); ralsei.fx = max(0, ralsei.fx - 0.1);
        if (press_k >= parry_at) { susie.pose = "parry"; ralsei.pose = "parry"; }
        if (press_k >= 1)
        {
            // everyone goes for it
            fin.st = "leap"; fin.t = 0;
            if (variable_global_exists("music")) audio_sound_gain(global.music, 0, round((white_up + white_stay) * 1000 / game_get_speed(gamespeed_fps)));
            audio_play_sound(snd_criticalswing, 1, false);
            audio_play_sound(snd_explosion, 1, false);
            do_shake(8, 30);
            // Susie, Ralsei & Pink leap at it; the others stay where they are and fire at it
            var _st = { x: titan_near.x, y: titan_near.y };
            array_push(leap, { name: "Susie",  spr: spr_susie_clash_jump, s: battle_s, x0: susie.sx,  y0: susie.y,  x1: _st.x - 30, y1: _st.y + 10, k: 0, h: 120, delay: 0, stay: false });
            array_push(leap, { name: "Ralsei", spr: spr_plat_ralsei_jump, s: 2,        x0: ralsei.sx, y0: ralsei.y, x1: _st.x - 50, y1: _st.y - 30, k: 0, h: 150, delay: 4, stay: false });
            for (var i = 0; i < array_length(allies); i++)
            {
                var _a = allies[i];
                var _y = segs[array_length(segs) - 1].y - _a.up;
                if (_a.jump)
                {
                    // Pink: crouches into her throw, leaps with it, and lets the bomb go up in the air (see "leap")
                    array_push(leap, { name: _a.name, spr: _a.atk, s: _a.s, x0: _a.x, y0: _y, x1: _st.x - 70, y1: _st.y - 50, k: 0, h: 170, delay: 0, stay: false,
                                       anim: true, f: 0, thrown: false });
                }
                else
                {
                    array_push(leap, { name: _a.name, spr: _a.atk, s: _a.s, x0: _a.x, y0: _y, x1: _a.x, y1: _y, k: 0, h: 0, delay: 0, stay: true });
                    array_push(volley, { spr: _a.shot, col: _a.col, x0: _a.x + 20, y0: _y - 50, x1: _st.x + irandom_range(-20, 20), y1: _st.y + irandom_range(-20, 20),
                                         k: 0, delay: 6 + i * 6, rot: 0 });
                }
            }
        }
    }
    break;

    case "leap":   // slow motion, the screen glowing white...
    {
        ts = lerp(1, slow_ts, min(1, fin.t / slow_in));
        box_k = max(0, box_k - 0.1);
        for (var i = 0; i < array_length(leap); i++)
        {
            var _l = leap[i];
            if (_l.delay > 0) { _l.delay -= ts; continue; }
            if (_l[$ "anim"] == true)
            {
                // Pink: her throw plays from the start; she's off the ground once she's crouched, and the bomb goes on its frame
                var _n = sprite_get_number(_l.spr);
                _l.f = min(_n - 1, _l.f + spd_of(_l.spr) * ts);
                if (_l.f >= pink_takeoff) _l.k = min(1, _l.k + ts / jump_frames);
                if (!_l.thrown && _l.f >= pink_bomb_frame)
                {
                    _l.thrown = true;
                    var _lx = lerp(_l.x0, _l.x1, _l.k), _ly = lerp(_l.y0, _l.y1, _l.k) - _l.h * 4 * _l.k * (1 - _l.k);
                    array_push(volley, { spr: spr_pinkbomb, col: c_white, x0: _lx + pink_bomb_at.x, y0: _ly + pink_bomb_at.y,
                                         x1: titan_near.x, y1: titan_near.y, k: 0, delay: 0, rot: 0 });
                    audio_play_sound(snd_smallswing, 1, false);
                }
            }
            else _l.k = min(1, _l.k + ts / jump_frames);
        }
        for (var i = 0; i < array_length(volley); i++)
        {
            var _v = volley[i];
            if (_v.delay > 0) _v.delay -= ts;
            else _v.k = min(1, _v.k + ts / volley_frames);
            _v.rot += 12 * ts;
        }
        white.to = 1; white.spd = 1 / white_up;
        if (white.a >= 1) { fin.st = "white"; fin.t = 0; }
    }
    break;

    case "white":   // ...held...
        if (fin.t >= white_stay) { fin.st = "black"; fin.t = 0; }
    break;

    case "black":   // ...then black
        black = min(1, fin.t / black_in);
        if (black >= 1)
        {
            white.a = 0; white.to = 0;
            fin.st = "damage"; fin.t = 0;
            // everyone's hit, adding up to what it's got left
            var _names = ["Susie", "Ralsei", "Queen", "Pink", "Jevil", "Spamton"];
            var _sum = 0;
            for (var i = 0; i < 6; i++)
            {
                var _amt = (i < 5) ? round(titan_hp * dmg_weights[$ _names[i]]) : titan_hp - _sum;
                _sum += _amt;
                var _a = -90 + i * 60;
                array_push(dmg_list, { name: _names[i], amount: max(0, _amt), x: lengthdir_x(170, _a), y: lengthdir_y(110, _a), t: -1 });
            }
        }
    break;

    case "damage":   // the numbers, one by one
    {
        for (var i = 0; i < array_length(dmg_list); i++)
        {
            var _d = dmg_list[i];
            if (_d.t < 0 && fin.t >= 20 + i * dmg_gap) { _d.t = 0; audio_play_sound(snd_damagetaken, 1, false); }
            if (_d.t >= 0) _d.t++;
        }
        if (fin.t >= 20 + array_length(dmg_list) * dmg_gap + dmg_hold)
        {
            fin.st = "done"; fin.t = 0;
            global.titan_defeated = true;
            // (next: the Castle Town scene)
            var _next = asset_get_index("scr_titan_epilogue_start");
            if (_next != -1) script_execute(_next);
        }
    }
    break;
}