// ============================================================ always running

// barrier
if (barrier.on)
{
    barrier.t++;
    barrier.grow  = min(barrier.grow + 1 / barrier_grow, 1);
    barrier.flash = max(barrier.flash - 0.08, 0);
}

// barrier shards
for (var i = array_length(shards) - 1; i >= 0; i--)
{
    var _p = shards[i];
    _p.t++;
    _p.vy += 0.25;
    _p.x += _p.vx;
    _p.y += _p.vy;
    _p.rot += _p.vr;
    if (_p.t >= 45) array_delete(shards, i, 1);
}

// spade chunks
for (var i = array_length(chunks) - 1; i >= 0; i--)
{
    var _c = chunks[i];
    _c.t++;
    _c.vy += 0.3;
    _c.x += _c.vx;
    _c.y += _c.vy;
    _c.rot += _c.vr;
    if (_c.t >= 30) array_delete(chunks, i, 1);
}

// spades: home in on their target, shatter the barrier if it's in the way
for (var i = array_length(spades) - 1; i >= 0; i--)
{
    var _s = spades[i];
    if (!instance_exists(_s.target)) { array_delete(spades, i, 1); continue; }
    var _m = body_mid(_s.target);
    var _d = point_distance(_s.x, _s.y, _m.x, _m.y);
    _s.rot += spade_spin;

    if (_d <= _s.speed)
    {
        spade_break(_m.x, _m.y);
        if (!is_undefined(_s.on_hit)) _s.on_hit();
        array_delete(spades, i, 1);
        continue;
    }

    var _dir = point_direction(_s.x, _s.y, _m.x, _m.y);
    _s.x += lengthdir_x(_s.speed, _dir);
    _s.y += lengthdir_y(_s.speed, _dir);

    if (barrier_touches(_s.x, _s.y, _s.speed)) barrier_shatter();
}

// heal beam
if (beam.on)
{
    if (!instance_exists(obj_ralsei)) { beam.on = false; saved.ralsei_up = true; }
    else
    {
        var _m = body_mid(obj_ralsei);
        beam.dir = point_direction(beam.x, beam.y, _m.x, _m.y);
        array_insert(beam.trail, 0, { x: beam.x, y: beam.y });
        if (array_length(beam.trail) > 6) array_pop(beam.trail);
        beam.frame += 0.25;

        if (point_distance(beam.x, beam.y, _m.x, _m.y) <= beam_speed)
        {
            beam.on = false;
            audio_play_sound(snd_heal, 1, false);
            var _f = instance_create_depth(0, 0, obj_ralsei.depth - 1, obj_heal_flash);
            _f.target   = obj_ralsei;
            _f.duration = 60;
            _f.on_finish = function()
            {
                pose(obj_ralsei, spr_ralsei_shocked, false); // up, shocked, right where he was lying
                saved.ralsei_up = true;
            };
        }
        else
        {
            beam.x += lengthdir_x(beam_speed, beam.dir);
            beam.y += lengthdir_y(beam_speed, beam.dir);
        }
    }
}

// ============================================================ the scene
if (!run_steps())
{
    scr_knight_finale_end(); // everything's done (the fade's already started)
    exit;
}

// ============================================================ actions
if (action == "") exit;
t++;

switch (action)
{
    // ------------------------------------------------ the Knight swoons Susie, she blocks it (same as round 2)
    case "first_block":
        switch (sub)
        {
            case "start":
                scr_knight_swoon_block_susie(spr_roark_slash_susie_2, 50);
                go("wait");
            break;

            case "wait":
                if (global.knight_swoon_done) finish();
            break;
        }
    break;

    // ------------------------------------------------ Susie blocks, faster and faster
    case "susie_rapid":
        switch (sub)
        {
            case "start":
                pose(obj_susie, spr_susie_defend, false);
                idx = 0;
                go("swoon");
            break;

            case "swoon":
                swoon(spr_roark_slash_susie_2, rapid_hits[idx].dur); // all on Susie
                go("swoon_wait");
            break;

            case "swoon_wait":
                if (!instance_exists(swoon_on))
                {
                    audio_play_sound(snd_impact, 1, false);
                    scr_camera_shake(3, 10);
                    zero_popup(obj_susie);
                    go("gap");
                }
            break;

            case "gap":
                if (t >= rapid_hits[idx].gap)
                {
                    idx++;
                    if (idx >= array_length(rapid_hits)) finish(); else go("swoon");
                }
            break;
        }
    break;

    // ------------------------------------------------ Ralsei, shocked, throws up a barrier
    case "ralsei_barrier":
        switch (sub)
        {
            case "start":
                if (!instance_exists(obj_ralsei)) { barrier_build(); go("grow"); break; }
                pose(obj_ralsei, spr_ralsei_shocked, false);
                go("shocked");
            break;

            case "shocked":
                if (t >= 30)
                {
                    pose(obj_ralsei, spr_ralsei_spell, false);
                    audio_play_sound(snd_spell_pacify, 1, false);
                    go("cast");
                }
            break;

            case "cast":
                if (!instance_exists(obj_ralsei) || obj_ralsei.sprite_index != spr_ralsei_spell
                    || floor(obj_ralsei.image_index) >= ralsei_cast_frame || t > 90)
                {
                    barrier_build();
                    audio_play_sound(snd_sparklegem, 1, false);
                    go("grow");
                }
            break;

            case "grow":
                // he holds the spell up once it's played out
                if (instance_exists(obj_ralsei) && obj_ralsei.sprite_index == spr_ralsei_spell && obj_ralsei.image_speed == 0)
                {
                    pose(obj_ralsei, spr_ralsei_spellready, true);
                }
                var _held = !instance_exists(obj_ralsei) || obj_ralsei.sprite_index != spr_ralsei_spell;
                if ((barrier.grow >= 1 && _held) || t > 150) finish();
            break;
        }
    break;

    // ------------------------------------------------ the Knight hits the barrier with everything
    case "barrier_barrage":
        switch (sub)
        {
            case "start":
                idx = 0;
                go("hit");
            break;

            case "hit":
            {
                var _k = power(idx / max(barrage_count - 1, 1), 0.7);
                saved.interval = round(lerp(barrage_int_a, barrage_int_b, _k));
                if (idx > 0) barrier_hit(); // the last one lands as this one cuts into it
                swoon((idx mod 2 == 0) ? spr_roark_slash_susie_2 : spr_roark_slash_ralsei, saved.interval + 6); // back and forth between them
                go("between");
            }
            break;

            case "between":
                if (t >= saved.interval)
                {
                    idx++;
                    if (idx >= barrage_count) go("last"); else go("hit");
                }
            break;

            case "last":
                if (!instance_exists(swoon_on)) { barrier_hit(); go("hold"); }
            break;

            case "hold":
                if (t >= barrage_hold) finish();
            break;
        }
    break;

    // ------------------------------------------------ King walks over and throws two spades
    case "king_spades":
        switch (sub)
        {
            case "start":
            {
                // he's not in this room: he walks up from below the screen, in his normal walk
                var _f   = party_front();
                var _cam = view_camera[0];
                var _cr  = camera_get_view_x(_cam) + camera_get_view_width(_cam);
                var _half = (sprite_get_bbox_right(spr_king_battle_idle) - sprite_get_bbox_left(spr_king_battle_idle) + 1) * 2 / 2;
                var _kx  = min(_f.x + king_stop_gap, _cr - king_edge_margin - _half - push_dist);
                var _sy  = camera_get_view_y(_cam) + camera_get_view_height(_cam) + king_spawn_pad
                           + (sprite_get_bbox_bottom(king_walk_sprite) - sprite_get_bbox_top(king_walk_sprite)) * 2;
                if (!instance_exists(obj_king)) instance_create_depth(_kx, _sy, -2000, obj_king);
                obj_king.visible = true;
                place_body(obj_king, king_walk_sprite, _kx, _sy);
                obj_king.image_index = 0;
                obj_king.image_speed = 1;
                saved.king_y = _f.y + king_ground_nudge;
                go("walk");
            }
            break;

            case "walk":
            {
                obj_king.y -= king_walk_speed;
                var _b = scr_get_body(obj_king);
                if (_b.y <= saved.king_y)
                {
                    obj_king.y += saved.king_y - _b.y;
                    obj_king.image_speed = 0; // stands there, still in his walk
                    obj_king.image_index = 0;
                    go("pre_cape");
                }
            }
            break;

            // his cape flies in onto his back (the dark screen), and he's in his battle pose
            case "pre_cape":
                if (t >= 20)
                {
                    var _cam = view_camera[0];
                    var _c = instance_create_depth(camera_get_view_x(_cam) + camera_get_view_width(_cam) + cape_spawn_pad,
                                                   obj_king.y + 37, -99999, obj_king_cape);
                    _c.laugh = false;
                    _c.on_merge = function() { pose(obj_king, spr_king_battle_idle, true); };
                    if (cape_sound != noone) audio_play_sound(cape_sound, 1, false);
                    go("cape");
                }
            break;

            case "cape":
                if (!instance_exists(obj_king_cape) || t > 240)
                {
                    with (obj_king_cape) instance_destroy();
                    if (obj_king.sprite_index != spr_king_battle_idle) pose(obj_king, spr_king_battle_idle, true);
                    go("wind");
                }
            break;

            case "wind":
                if (t >= king_wind)
                {
                    throw_spade(obj_susie, spade_speed, function()
                    {
                        barrier_shatter(); // in case it slipped past it somehow
                        pose(obj_susie, spr_susie_backlash, false);
                        audio_play_sound(snd_hurt, 1, false);
                        scr_camera_shake(4, 12);
                    });
                    go("second");
                }
            break;

            case "second":
                if (t >= spade_gap)
                {
                    throw_spade(obj_ralsei, spade_speed, function()
                    {
                        barrier_shatter();
                        pose(obj_ralsei, spr_ralsei_shocked, false);
                        audio_play_sound(snd_hurt, 1, false);
                        scr_camera_shake(4, 12);
                    });
                    go("flying");
                }
            break;

            case "flying":
                if (array_length(spades) == 0)
                {
                    barrier_shatter(); // no spades could be thrown (King missing): still drop it
                    go("hold");
                }
            break;

            case "hold":
                if (t >= 30) finish();
            break;
        }
    break;

    // ------------------------------------------------ both swooned, one after the other
    case "double_swoon":
        switch (sub)
        {
            case "start":
                swoon(spr_roark_slash_susie_2, 45);
                go("s1");
            break;

            case "s1":
                if (!instance_exists(swoon_on))
                {
                    pose(obj_susie, spr_susie_fell, false);
                    scr_swoon_fall_sounds();
                    scr_camera_shake(4, 20);
                    swoon_popup(obj_susie);
                    go("gap");
                }
            break;

            case "gap":
                if (t >= 12) { swoon(spr_roark_slash_ralsei, 45); go("s2"); }
            break;

            case "s2":
                if (!instance_exists(swoon_on))
                {
                    pose(obj_ralsei, spr_ralsei_defeat, false);
                    scr_swoon_fall_sounds();
                    scr_camera_shake(4, 20);
                    swoon_popup(obj_ralsei);
                    go("hold");
                }
            break;

            case "hold":
                if (t >= 30) finish();
            break;
        }
    break;

    // ------------------------------------------------ the Knight turns back into the ball and fades into the castle door
    case "knight_leave":
        switch (sub)
        {
            case "start":
                if (!instance_exists(obj_knight)) { finish(); break; }
                obj_knight.exit_dir = sign(obj_knight.image_xscale); // keep facing the way he is: no turning around before he flies off
                scr_knight_to_ball();
                go("reverse");
            break;

            case "reverse":
                // the moment he's the ball (reverse_phase 2 = about to fly off sideways), take over
                if (!instance_exists(obj_knight)) { finish(); break; }
                if (obj_knight.reverse_phase == 2 || t > 150)
                {
                    var _c = body_mid(obj_knight);
                    ball.on    = true;
                    ball.x     = _c.x;  ball.y  = _c.y;
                    ball.sx    = _c.x;  ball.sy = _c.y;
                    ball.tx    = door_x; ball.ty = door_y;
                    ball.xs    = sign(obj_knight.image_xscale);
                    ball.scale = abs(obj_knight.image_xscale);
                    ball.alpha = 1;
                    ball.frame = 0;
                    ball.t     = 0;
                    obj_knight.reverse_phase = 0;
                    obj_knight.visible = false;
                    go("fly");
                }
            break;

            case "fly":
            {
                ball.t++;
                var _k = min(ball.t / leave_frames, 1);
                var _e = (_k < 0.5) ? 2 * _k * _k : 1 - power(-2 * _k + 2, 2) / 2;
                ball.x = lerp(ball.sx, ball.tx, _e);
                ball.y = lerp(ball.sy, ball.ty, _e);
                ball.alpha = (_k < 0.5) ? 1 : 1 - (_k - 0.5) / 0.5;
                ball.frame += sprite_get_speed(spr_roark_ball) / game_get_speed(gamespeed_fps);
                if (_k >= 1)
                {
                    ball.on = false;
                    with (obj_knight) instance_destroy();
                    go("hold");
                }
            }
            break;

            case "hold":
                if (t >= 10) finish();
            break;
        }
    break;

    // ------------------------------------------------ both of them struggling on the ground
    case "struggle":
        switch (sub)
        {
            case "start":
                pose(obj_susie,  spr_susie_landed, false);
                pose(obj_ralsei, spr_ralsei_fall_wince, false);
                saved.sx = instance_exists(obj_susie)  ? obj_susie.x  : 0;
                saved.rx = instance_exists(obj_ralsei) ? obj_ralsei.x : 0;
                go("shake");
            break;

            case "shake":
            {
                // little shudders, on and off
                var _j = ((t mod 16) < 8) ? (((t div 2) mod 2 == 0) ? 1 : -1) : 0;
                if (instance_exists(obj_susie))  obj_susie.x  = saved.sx + _j;
                if (instance_exists(obj_ralsei)) obj_ralsei.x = saved.rx - _j;
                if (t >= struggle_frames)
                {
                    if (instance_exists(obj_susie))  obj_susie.x  = saved.sx;
                    if (instance_exists(obj_ralsei)) obj_ralsei.x = saved.rx;
                    finish();
                }
            }
            break;
        }
    break;

    // ------------------------------------------------ Susie gets up and starts for the castle
    case "susie_getup":
        switch (sub)
        {
            case "start":
                if (!instance_exists(obj_susie)) { finish(); break; }
                pose(obj_susie, spr_susie_getup, false);
                go("rise");
            break;

            case "rise":
                if (t > 2 && obj_susie.image_speed == 0)
                {
                    pose(obj_susie, spr_susie_walk_right_upset, true);
                    obj_susie.image_speed = getup_anim_speed;
                    saved.walked = 0;
                    go("walk");
                }
            break;

            case "walk":
                obj_susie.x += getup_walk_speed;
                saved.walked += getup_walk_speed;
                if (saved.walked >= getup_walk_dist)
                {
                    pose(obj_susie, spr_susie_walk_down_neutral, true);
                    obj_susie.image_speed = getup_anim_speed;
                    saved.walked = 0;
                    go("down");
                }
            break;

            case "down":
                obj_susie.y += getup_walk_speed;
                saved.walked += getup_walk_speed;
                if (saved.walked >= getup_down_dist)
                {
                    // stops facing King
                    pose(obj_susie, spr_susie_walk_right_upset, false);
                    obj_susie.image_speed = 0;
                    obj_susie.image_index = 0;
                    finish();
                }
            break;
        }
    break;

    // ------------------------------------------------ King throws at her, she blocks and Rude Busters him back
    case "king_counter":
        switch (sub)
        {
            case "start":
                if (!instance_exists(obj_king) || !instance_exists(obj_susie)) { finish(); break; }
                saved.blocked = false;
                pose(obj_king, spr_king_battle_idle, true);
                go("wind");
            break;

            case "wind":
                if (t >= 15)
                {
                    throw_spade(obj_susie, counter_spade_speed, function()
                    {
                        audio_play_sound(snd_impact, 1, false);
                        scr_camera_shake(3, 10);
                        saved.blocked = true;
                    });
                    go("incoming");
                }
            break;

            case "incoming":
                // she snaps her guard up as it gets close
                if (array_length(spades) > 0 && instance_exists(obj_susie) && obj_susie.sprite_index != spr_susie_defend)
                {
                    var _m = body_mid(obj_susie);
                    if (point_distance(spades[0].x, spades[0].y, _m.x, _m.y) <= defend_at_dist)
                    {
                        pose(obj_susie, spr_susie_defend, false);
                        audio_play_sound(snd_smallswing, 1, false);
                    }
                }
                if (saved.blocked || array_length(spades) == 0) go("pre_buster");
            break;

            case "pre_buster":
                if (t >= buster_delay)
                {
                    buster = instance_create_depth(0, 0, depth - 1, obj_rude_buster);
                    buster.break_on_hit = false;
                    var _k = body_mid(obj_king);
                    buster.target_x = _k.x;
                    buster.target_y = _k.y;
                    go("buster");
                }
            break;

            case "buster":
                if (instance_exists(buster) && buster.state == "windup" && instance_exists(obj_king))
                {
                    var _k = body_mid(obj_king);
                    buster.target_x = _k.x;
                    buster.target_y = _k.y;
                }
                if (!instance_exists(buster) || buster.landed || t > 180)
                {
                    // it lands: King gets knocked back
                    pose(obj_king, spr_king_hurt, false);
                    audio_play_sound(snd_impact, 1, false);
                    audio_play_sound(snd_damagetaken, 1, false);
                    scr_camera_shake(5, 14);
                    saved.kx = obj_king.x;
                    go("push");
                }
            break;

            case "push":
            {
                var _k = min(t / push_frames, 1);
                obj_king.x = saved.kx + push_dist * (1 - power(1 - _k, 3));
                if (t >= push_frames)
                {
                    // his cape tears off and flies back the way it came
                    var _c = instance_create_depth(obj_king.x + 46, obj_king.y + 37, obj_king.depth - 1, obj_king_cape);
                    _c.mode = "leave";
                    _c.dark = false;
                    if (cape_sound != noone) audio_play_sound(cape_sound, 1, false);
                    pose(obj_king, king_stand_sprite, false);
                    obj_king.image_speed = 0;
                    obj_king.image_index = 0;
                    go("stagger");
                }
            }
            break;

            // a second later he drops to his knees
            case "stagger":
                if (t >= king_fall_delay)
                {
                    pose(obj_king, spr_king_kneel_sad, false);
                    audio_play_sound(snd_impact, 1, false);
                    scr_camera_shake(2, 10);
                    go("wait_susie");
                }
            break;

            case "wait_susie":
                // the buster puts her back in battle idle once her swing's played out
                if (!instance_exists(buster) || t > 120) finish();
            break;
        }
    break;

    // ------------------------------------------------ Susie heals Ralsei from a distance
    case "heal_beam":
        switch (sub)
        {
            case "start":
                if (!instance_exists(obj_susie)) { finish(); break; }
                saved.fired     = false;
                saved.ending    = false;
                saved.susie_ok  = false;
                saved.ralsei_up = !instance_exists(obj_ralsei);
                pose(obj_susie, spr_susie_left_neutral, false); // turns around to face Ralsei
                go("turn");
            break;

            case "turn":
                if (t >= turn_hold)
                {
                    pose(obj_susie, spr_susie_heal, false);
                    charge_snd = scr_audio_fade_in(snd_charge, 1000, 1, true);
                    go("charge");
                }
            break;

            case "charge":
                // the beam leaves her hand on heal_frame
                if (!saved.fired && obj_susie.sprite_index == spr_susie_heal && floor(obj_susie.image_index) >= heal_frame)
                {
                    var _m = body_mid(obj_susie);
                    beam.on = true;
                    beam.x = _m.x + hand_off_x * sign(obj_susie.image_xscale);
                    beam.y = _m.y + hand_off_y;
                    beam.trail = [];
                    beam.frame = 0;
                    saved.fired = true;
                }

                // her charge winds down
                if (!saved.ending && obj_susie.sprite_index == spr_susie_heal && obj_susie.image_speed == 0)
                {
                    pose(obj_susie, spr_susie_heal_end, false);
                    if (charge_snd != -1) audio_sound_gain(charge_snd, 0, 400);
                    saved.ending = true;
                }
                if (saved.ending && !saved.susie_ok && obj_susie.sprite_index == spr_susie_heal_end && obj_susie.image_speed == 0)
                {
                    pose(obj_susie, spr_susie_left_neutral, false);
                    if (charge_snd != -1) { audio_stop_sound(charge_snd); charge_snd = -1; }
                    saved.susie_ok = true;
                }

                if ((saved.susie_ok && saved.ralsei_up) || t > 600) go("hold");
            break;

            case "hold":
                if (t >= 30)
                {
                    pose(obj_ralsei, spr_ralsei_walk_right_neutral, false);
                    if (instance_exists(obj_ralsei)) obj_ralsei.image_speed = 0;
                    finish();
                }
            break;
        }
    break;

    // ------------------------------------------------ both run to the castle door, then a quick fade into the next room
    case "run_inside":
        switch (sub)
        {
            case "start":
                runners = [
                    { obj: obj_susie,  spr_l: spr_susie_walk_left_neutral,  spr_r: spr_susie_walk_right_neutral,  spr_up: spr_susie_walk_up,
                      off: 10,  wait: 0,               phase: "wait", dir: 1 },
                    { obj: obj_ralsei, spr_l: spr_ralsei_walk_left_neutral, spr_r: spr_ralsei_walk_right, spr_up: spr_ralsei_walk_up,
                      off: -14, wait: ralsei_run_wait, phase: "wait", dir: 1 }
                ];
                go("run");
            break;

            case "run":
            {
                var _all_there = true;
                for (var i = 0; i < array_length(runners); i++)
                {
                    var _r = runners[i];
                    if (_r.phase == "there") continue;
                    if (!instance_exists(_r.obj)) { _r.phase = "there"; continue; }

                    // made it: fade out right there
                    if (_r.phase == "fade")
                    {
                        _r.obj.image_alpha = max(_r.obj.image_alpha - run_fade_speed, 0);
                        if (_r.obj.image_alpha <= 0) { _r.obj.visible = false; _r.phase = "there"; }
                        else _all_there = false;
                        continue;
                    }
                    _all_there = false;
                    var _o = _r.obj;

                    switch (_r.phase)
                    {
                        case "wait":
                            _r.wait--;
                            if (_r.wait <= 0)
                            {
                                var _f = scr_get_feet(_o);
                                _r.dir = (door_x + _r.off >= _f.x) ? 1 : -1;
                                pose(_o, (_r.dir < 0) ? _r.spr_l : _r.spr_r, true);
                                _o.image_speed = 1.5;
                                _r.phase = "side";
                            }
                        break;

                        // across to line up under the door...
                        case "side":
                        {
                            _o.x += _r.dir * run_speed;
                            var _f = scr_get_feet(_o);
                            if ((door_x + _r.off - _f.x) * _r.dir <= 0)
                            {
                                _o.x += door_x + _r.off - _f.x; // exactly in line
                                pose(_o, _r.spr_up, true);
                                _o.image_speed = 1.5;
                                _r.phase = "up";
                            }
                        }
                        break;

                        // ...then up into it
                        case "up":
                        {
                            _o.y -= run_speed;
                            var _f = scr_get_feet(_o);
                            var _ty = door_y - run_extra_up;
                            if (_f.y <= _ty)
                            {
                                _o.y += _ty - _f.y;
                                _r.phase = "fade"; // keeps walking in place while it fades
                            }
                        }
                        break;
                    }
                }
                if (_all_there)
                {
                    // both gone through the door: quick fade out, into the next room, quick fade in
                    room_persistent = true;   // keep the room exactly like this for when the story comes back here
                    var _fader = instance_create_depth(0, 0, -10004, obj_cutscenefade);
                    _fader.fade_target   = 1;
                    _fader.fade_step     = exit_fade_step;
                    _fader.target_room   = next_room;
                    _fader.wait_duration = exit_fade_hold;
                    finish();
                }
            }
            break;
        }
    break;
}