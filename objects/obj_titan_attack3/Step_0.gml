// ---------------------------------------------------------------- the script
if (step_i < array_length(steps))
{
    var _st = steps[step_i];
    if (!step_on)
    {
        step_on = true;
        step_t  = 0;
        if (_st.run != undefined) _st.run();
        if (!instance_exists(id)) exit;   // (the last step)
    }
    var _ok = (_st.until == undefined) || _st.until();
    if (_ok)
    {
        step_t++;
        if (step_t > _st.wait) { step_i++; step_on = false; }
    }
}

// ---------------------------------------------------------------- King's attack starting (before she snaps): spades from
// alternating sides, each gliding in to just outside the box, waiting a moment, then coming across (like attack 1's)
if (opening && box_up())
{
    open_t++;
    if (open_t >= open_spade_start && (open_t - open_spade_start) mod open_spade_every == 0)
    {
        var _in   = scr_get_box_interior();
        var _side = next_side;
        next_side = -next_side;
        var _lx = (_side < 0) ? _in.x1 - open_spade_off : _in.x2 + open_spade_off;
        var _ly = random_range(_in.y1 + 10, _in.y2 - 10);
        var _sx = _lx + _side * open_spade_glide;
        var _s  = instance_create_depth(_sx, _ly, obj_battlebox.depth - 1, obj_spadebullet);
        _s.lx = _sx; _s.ly = _ly;
        _s.dir = -_side;
        _s.move_speed = open_spade_speed;
        _s.damage = wave_spade_dmg;
        _s.image_xscale = _s.dir; _s.image_yscale = 1;
        _s.travel_out = open_spade_off;
        _s.approach_to = _lx;
        _s.approach_frames = open_spade_glide_time;
        _s.wait_frames = open_spade_wait;
        _s.show_outside = true;
        audio_play_sound(snd_swing, 1, false, 0.5);
    }
}

// Susie tumbling as she's knocked flying
if (tumble && instance_exists(obj_susie)) obj_susie.image_angle += fling_spin;

// ---------------------------------------------------------------- Susie shaking in place, harder and harder
if (shake.on && instance_exists(obj_susie))
{
    shake.t++;
    var _amt = min(shake.t / shake_ramp, 1) * shake_max;
    if (shake.t mod 2 == 0) obj_susie.x = shake.base + round(choose(-1, 1) * _amt);
}

// ---------------------------------------------------------------- Susie running at King
if (runner != undefined && instance_exists(obj_susie))
{
    var _f  = scr_get_feet(obj_susie);
    var _dx = runner.tx - _f.x, _dy = runner.ty - _f.y;
    var _d  = point_distance(0, 0, _dx, _dy);
    if (_d <= susie_run_speed) { obj_susie.x += _dx; obj_susie.y += _dy; runner = undefined; }
    else { obj_susie.x += _dx / _d * susie_run_speed; obj_susie.y += _dy / _d * susie_run_speed; }
}

// ---------------------------------------------------------------- King's frame-by-frame animations
if (king_anim != undefined && instance_exists(obj_king))
{
    king_anim.f += king_anim.spd;
    var _n = sprite_get_number(king_anim.spr);
    if (king_anim.loop) king_anim.f = king_anim.f mod _n;
    else king_anim.f = min(king_anim.f, _n - 1);
    if (obj_king.sprite_index == king_anim.spr) obj_king.image_index = floor(king_anim.f);
}

// ---------------------------------------------------------------- King's chain attack (Deltarune's obj_wavechain)
if (wave != undefined)
{
    var _w = wave;
    _w.t++;
    switch (_w.phase)
    {
        case "extend":
            // shoots out at the box, a link every couple of frames
            _w.hx += _w.dir * chain_speed;
            if (_w.t mod chain_piece_gap == 0) array_push(_w.pieces, { x0: _w.hx, y0: _w.hy, x: _w.hx, y: _w.hy, s: random(100) });
            if ((_w.dir < 0 && _w.hx <= _w.box_x) || (_w.dir > 0 && _w.hx >= _w.box_x))
            {
                audio_stop_sound(_w.snd_extend);
                _w.snd_extend = noone;
                audio_play_sound(snd_locker, 1, false);
                audio_play_sound(snd_screenshake, 1, false);
                _w.phase = "lock";
            }
        break;

        case "lock":
            // the box (and the SOUL in it) shakes, less and less
            var _sx = 0, _sy = 0;
            if (_w.shake > 0) { var _sd = random(360); _sx = lengthdir_x(_w.shake, _sd); _sy = lengthdir_y(_w.shake, _sd); }
            if (instance_exists(obj_battlebox))
            {
                obj_battlebox.box_base_x = _w.box_x - obj_battlebox.raw_width / 2 + _sx;
                obj_battlebox.box_base_y = _w.box_y - obj_battlebox.raw_height / 2 + _sy;
            }
            with (obj_soul) { x += _sx - other.wave.off_x; y += _sy - other.wave.off_y; }
            _w.off_x = _sx; _w.off_y = _sy;
            _w.shake--;
            if (_w.shake < 0)
            {
                with (obj_soul) { x -= other.wave.off_x; y -= other.wave.off_y; }
                _w.off_x = 0; _w.off_y = 0;
                _w.snd_wave = audio_play_sound(snd_chain_wave, 5, true);
                _w.phase = "swing";
            }
        break;

        case "swing":
        {
            // King bobs up and down, and the wave runs down the chain to the box on the end of it
            _w.siner++;
            if (instance_exists(obj_king)) obj_king.y = _w.king_y + sin(_w.siner / wave_slow) * wave_height;
            if (_w.snd_wave != noone) audio_sound_pitch(_w.snd_wave, max(0.1, 0.9 - sin(_w.siner / wave_slow) / 2));

            // spades in from the left side of the screen, at the box's first height
            _w.btimer++;
            if (_w.btimer >= wave_spade_every && instance_exists(obj_battlebox))
            {
                _w.btimer = 0;
                var _lx = cam() - 20;
                var _s = instance_create_depth(_lx, _w.box_y, obj_battlebox.depth - 1, obj_spadebullet);
                _s.lx = _lx; _s.ly = _w.box_y;
                _s.dir = 1;
                _s.move_speed = wave_spade_speed;
                _s.damage = wave_spade_dmg;
                _s.image_xscale = 1; _s.image_yscale = 1;
                _s.travel_out = 40;
            }

            // the rails: a solid line of spades along the top of the box going right, and along the bottom going left
            _w.rtimer++;
            if (_w.rtimer >= rail_every && instance_exists(obj_battlebox))
            {
                _w.rtimer = 0;
                var _in = scr_get_box_interior();
                var _cy = (_in.y1 + _in.y2) / 2;
                for (var _r = -1; _r <= 1; _r += 2)
                {
                    var _rx = (_r < 0) ? _in.x1 - 20 : _in.x2 + 20;
                    var _rs = instance_create_depth(_rx, _cy + _r * rail_off, obj_battlebox.depth - 1, obj_spadebullet);
                    _rs.lx = _rx; _rs.ly = _cy + _r * rail_off;
                    _rs.dir = -_r;   // (the top one from the left going right, the bottom one from the right going left)
                    _rs.move_speed = rail_speed;
                    _rs.damage = wave_spade_dmg;
                    _rs.image_xscale = _rs.dir; _rs.image_yscale = 1;
                    _rs.travel_out = 20;
                    array_push(_w.rails, _rs);
                }
            }
        }
        break;

        case "gone":
            // the links fade, King settles back where he was
            _w.fade -= 0.1;
            if (instance_exists(obj_king)) obj_king.y = lerp(obj_king.y, _w.king_y, 0.2);
            if (_w.fade <= 0)
            {
                if (instance_exists(obj_king)) obj_king.y = _w.king_y;
                wave = undefined;
            }
        break;
    }

    // every link follows how far King's moved, a couple of frames later than the one before it (the box: the last one)
    if (wave != undefined && (_w.phase == "swing" || _w.phase == "gone"))
    {
        var _ky = instance_exists(obj_king) ? obj_king.y - _w.king_y : 0;
        array_insert(_w.hist, 0, _ky);
        var _n = array_length(_w.pieces);
        var _keep = _n * chain_piece_gap + 2;
        if (array_length(_w.hist) > _keep) array_resize(_w.hist, _keep);
        var _hl = array_length(_w.hist);
        for (var i = 0; i < _n; i++)
        {
            var _p = _w.pieces[i];
            _p.y = _p.y0 + _w.hist[min(i * chain_piece_gap, _hl - 1)];
        }
        if (_w.phase == "swing" && instance_exists(obj_battlebox))
        {
            var _by  = _w.box_y + _w.hist[min(_n * chain_piece_gap, _hl - 1)];
            var _old = scr_box_center().y;
            obj_battlebox.box_base_y = _by - obj_battlebox.raw_height / 2;
            obj_battlebox.y = obj_battlebox.box_base_y + (obj_battlebox.raw_height - obj_battlebox.raw_height * obj_battlebox.image_yscale) / 2;
            var _moved = scr_box_center().y - _old;
            with (obj_soul) y += _moved;   // (carried along with it)
            // the rails move with the box too
            for (var i = array_length(_w.rails) - 1; i >= 0; i--)
            {
                var _rr = _w.rails[i];
                if (!instance_exists(_rr)) { array_delete(_w.rails, i, 1); continue; }
                _rr.ly += _moved;
            }
        }
    }
}

// ---------------------------------------------------------------- Susie's axes
if (throwing && instance_exists(obj_susie))
{
    throw_t++;
    obj_susie.image_index = min(5, obj_susie.image_index + throw_anim_speed);
    if (throw_t >= axe_start && throw_t < axe_time - axe_last_gap && (throw_t - axe_start) mod axe_every == 0) throw_axe();
    if (throw_t >= axe_time) throwing = false;
}
for (var i = array_length(axes) - 1; i >= 0; i--)
{
    var _a = axes[i];
    _a.vx -= axe_gravity;   // back toward her
    _a.x  += _a.vx;
    _a.y  += _a.vy;
    _a.spin_t++;
    if (_a.spin_t >= 6) { _a.spin_t = 0; _a.ang -= 45; }
    if (axes_fading) { _a.a -= 0.1; if (_a.a <= 0) { array_delete(axes, i, 1); continue; } }
    // King's SOUL
    if (ksoul != undefined && !axes_fading && !_a.hit && ksoul.inv <= 0 && point_distance(_a.x, _a.y, ksoul.x, ksoul.y) <= axe_hit_r)
    {
        _a.hit = true;
        ksoul.inv = ksoul_inv;
        var _kt = king_target();
        if (instance_exists(_kt)) _kt.take_hit(round(axe_damage * random_range(0.9, 1.1)), susie_col);
        scr_camera_shake(2, 6);
    }
    if (_a.x < cam() - 60) array_delete(axes, i, 1);
}

// ---------------------------------------------------------------- King's SOUL: dodges the axes it sees coming
if (ksoul != undefined)
{
    var _k = ksoul;
    if (_k.inv > 0) _k.inv--;
    if (instance_exists(obj_battlebox) && obj_battlebox.state != "closing")
    {
        _k.a = min(1, _k.a + 0.1);
        var _in = scr_get_box_interior();
        var _m  = 8;
        var _c  = { x: (_in.x1 + _in.x2) / 2, y: (_in.y1 + _in.y2) / 2 };
        var _mx = 0, _my = 0, _threat = false;
        for (var i = 0; i < array_length(axes); i++)
        {
            var _a = axes[i];
            if (!_a.seen || _a.hit) continue;
            // where it'll be over the next few frames: the closest it gets to the SOUL
            var _px = _a.x, _py = _a.y, _pvx = _a.vx, _best = 9999, _bx = _px, _by = _py;
            for (var j = 0; j < ksoul_look; j++)
            {
                _pvx -= axe_gravity; _px += _pvx; _py += _a.vy;
                var _dd = point_distance(_px, _py, _k.x, _k.y);
                if (_dd < _best) { _best = _dd; _bx = _px; _by = _py; }
            }
            if (_best < ksoul_clear)
            {
                _threat = true;
                var _away = sign(_k.y - _by);
                if (_away == 0) _away = (_k.y < _c.y) ? -1 : 1;
                // no room that way: go the other way (past it)
                if ((_away < 0 && _k.y - _in.y1 < _m + 10) || (_away > 0 && _in.y2 - _k.y < _m + 10)) _away = -_away;
                _my += _away;
                _mx += sign(_k.x - _bx) * 0.3;
            }
        }
        if (_threat)
        {
            var _l = max(0.001, point_distance(0, 0, _mx, _my));
            _k.x += _mx / _l * ksoul_speed;
            _k.y += _my / _l * ksoul_speed;
        }
        else
        {
            // drifts round the middle while nothing's coming
            _k.wander += random_range(-8, 8);
            var _tx = _c.x + lengthdir_x(20, _k.wander), _ty = _c.y + lengthdir_y(14, _k.wander);
            _k.x += clamp(_tx - _k.x, -0.8, 0.8);
            _k.y += clamp(_ty - _k.y, -0.8, 0.8);
        }
        _k.x = clamp(_k.x, _in.x1 + _m, _in.x2 - _m);
        _k.y = clamp(_k.y, _in.y1 + _m, _in.y2 - _m);
    }
    else _k.a = max(0, _k.a - 0.1);
}

// ---------------------------------------------------------------- King's chain reaching out to Susie's SOUL
if (grab != undefined && instance_exists(obj_king) && instance_exists(obj_susie) && !grab.locked)
{
    var _h = king_hand_pos(), _sp = ssoul_pos();
    grab.len += grab_speed;
    if (grab.len >= point_distance(_h.x, _h.y, _sp.x, _sp.y))
    {
        grab.locked = true;
        if (grab.snd != noone) audio_stop_sound(grab.snd);
        grab.snd = noone;
        audio_play_sound(snd_locker, 1, false);
        audio_play_sound(snd_screenshake, 1, false);
        scr_camera_shake(6, 16);
        pose(obj_susie, spr_susie_shocked, 1, 1);
        with (obj_susie) { image_speed = 0; image_index = 0; }
    }
}
if (ssoul != undefined) ssoul.scale = min(1, ssoul.scale + 0.1);

// ---------------------------------------------------------------- Ralsei's fireshock (and Lancer's spade)
if (fire != undefined)
{
    var _fi = fire;
    _fi.f += 7 / 60;
    _fi.x += _fi.vx;
    _fi.y += _fi.vy;
    if (!_fi.parried)
    {
        // Lancer throws the moment his spade would get there just in time
        var _kx = feet(obj_king).x + parry_before;
        if (!_fi.hit && instance_exists(obj_lancer))
        {
            var _left = (_fi.x - _kx) / max(0.001, -_fi.vx);   // frames till it's there
            var _px = _kx, _py = _fi.y + _fi.vy * max(0, _left);
            var _lm = mid(obj_lancer);
            if (_left <= point_distance(_lm.x, _lm.y, _px, _py) / parry_spade_speed)
            {
                _fi.hit = true;
                scene.add_spade(_lm.x, _lm.y, _px, _py, parry_spade_speed, 0, function() { parry_fire(); });
            }
        }
        if (_fi.x <= _kx - 30) parry_fire();   // (just in case: it never reaches him)
    }
    else
    {
        // knocked away, tumbling up and off
        _fi.vy  += 0.35;
        _fi.rot += 15;
        _fi.a   -= 0.02;
        if (_fi.a <= 0 || _fi.y > camera_get_view_y(view_camera[0]) + 560) fire = undefined;
    }
}

// ---------------------------------------------------------------- swung round on the chain, then thrown
// ---------------------------------------------------------------- swung round on the chain, then thrown
if (spin != undefined && instance_exists(obj_susie))
{
    var _sp = spin;
    // afterimages
    if (_sp.phase != "gone")
    {
        array_insert(_sp.trail, 0, { x: obj_susie.x, y: obj_susie.y, ang: obj_susie.image_angle, spr: obj_susie.sprite_index,
                                     img: obj_susie.image_index, xs: obj_susie.image_xscale, ys: obj_susie.image_yscale });
        if (array_length(_sp.trail) > spin_trail) array_resize(_sp.trail, spin_trail);
    }
    switch (_sp.phase)
    {
        case "swing":
        {
            _sp.t++;
            var _p = king_spin_pos();
            var _prev = _sp.ang;
            // speeds up smoothly, reeled in smoothly
            var _ramp = min(1, _sp.t / spin_ramp);
            _sp.w = spin_max * _ramp * _ramp * (3 - 2 * _ramp);
            _sp.ang += _sp.w;
            _sp.total += _sp.w;
            var _pull = min(1, _sp.t / spin_pull_time);
            _sp.r = lerp(_sp.r0, spin_radius, _pull * _pull * (3 - 2 * _pull));
            if (floor(_sp.total / 360) > _sp.last_whoosh) { _sp.last_whoosh = floor(_sp.total / 360); audio_play_sound(snd_heavyswing, 1, false); }
            // her SOUL on the end of the chain, her head toward him
            obj_susie.image_angle = _sp.ang + 90;
            var _sx = _p.x + lengthdir_x(_sp.r, _sp.ang), _sy = _p.y + lengthdir_y(_sp.r, _sp.ang);
            var _now = ssoul_pos();
            obj_susie.x += _sx - _now.x;
            obj_susie.y += _sy - _now.y;
            // let go at the top (going round anticlockwise, she flies off to the left), with the speed she had
            var _a0 = ((_prev mod 360) + 360) mod 360, _a1 = ((_sp.ang mod 360) + 360) mod 360;
            if (_sp.total >= 360 * spin_turns && _a0 < 90 && _a1 >= 90)
            {
                var _v = min(throw_max, degtorad(_sp.w) * _sp.r);
                _sp.phase = "fly";
                _sp.vx = lengthdir_x(_v, _sp.ang + 90);
                _sp.vy = lengthdir_y(_v, _sp.ang + 90);
                grab = undefined;
                audio_play_sound(snd_ultraswing, 1, false);
                cam_follow = true;
                scr_call_after_frames(function() { king_stop(spr_king_battle_idle); }, 20);
            }
        }
        break;

        case "fly":
            _sp.vy += throw_gravity;
            obj_susie.x += _sp.vx;
            obj_susie.y += _sp.vy;
            obj_susie.image_angle += _sp.w;   // (still turning as fast as she was)
            if (obj_susie.y > camera_get_view_y(view_camera[0]) + 480 + 120 || obj_susie.x < -120)
            {
                _sp.phase = "gone";
                obj_susie.visible = false;
                ssoul = undefined;
                cam_follow = false;
            }
        break;
    }
}
// the camera follows her off the edge (only ever left: it stops at the room's edge)
if (cam_follow && instance_exists(obj_susie) && instance_exists(scene))
{
    var _tx = clamp(obj_susie.x - vw * 0.35, 0, cam());
    if (_tx < cam()) scene.set_cam(lerp(cam(), _tx, 0.25));
}

// ---------------------------------------------------------------- people walking straight somewhere
for (var i = array_length(movers) - 1; i >= 0; i--)
{
    var _mv = movers[i];
    if (!instance_exists(_mv.o)) { array_delete(movers, i, 1); continue; }
    var _f  = scr_get_feet(_mv.o);
    var _dx = _mv.tx - _f.x, _dy = _mv.ty - _f.y;
    var _d  = point_distance(0, 0, _dx, _dy);
    if (_d <= _mv.spd) { _mv.o.x += _dx; _mv.o.y += _dy; array_delete(movers, i, 1); }
    else { _mv.o.x += _dx / _d * _mv.spd; _mv.o.y += _dy / _d * _mv.spd; }
}

// ---------------------------------------------------------------- Ralsei running to the edge, slowing right at the end
if (ral != undefined && ral.spd > 0 && instance_exists(obj_ralsei))
{
    var _f   = scr_get_feet(obj_ralsei);
    var _rem = _f.x - ralsei_stop_x;
    if (_rem <= ralsei_slow_from && !ral.slowed)
    {
        ral.slowed = true;
        if (variable_global_exists("music")) scr_audio_fade_out(global.music, music_fade_ms);
    }
    ral.spd = (_rem > ralsei_slow_from) ? ralsei_run_speed : ralsei_run_speed * _rem / ralsei_slow_from;
    obj_ralsei.image_speed = max(0.3, ral.spd / ralsei_run_speed);
    if (ral.spd < 0.4 || _rem <= 0)
    {
        ral.spd = 0;
        scene.face(obj_ralsei, spr_ralsei_walk_left_neutral);
        with (obj_ralsei) { image_speed = 0; image_index = 0; }
    }
    else obj_ralsei.x -= min(ral.spd, _rem);
}