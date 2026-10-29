// Z / X presses for this frame (only the moment they go down, never the key repeat)
var _ok_down   = keyboard_check(ord("Z")) || keyboard_check(vk_enter);
var _back_down = keyboard_check(ord("X")) || keyboard_check(vk_shift);
ok_press   = _ok_down && !ok_prev;
back_press = _back_down && !back_prev;
ok_prev    = _ok_down;
back_prev  = _back_down;

// the boxes rise while the menu's up, and drop back for the enemies' turn so the battle box has room
var _menu_up = (state == "choose" || state == "exec_next" || state == "exec_run" || state == "fight" || state == "win");
if (instance_exists(obj_UI)) obj_UI.menu_lift_target = _menu_up ? panel_lift : 0;
panel_y = panel_y_base - (instance_exists(obj_UI) ? round(obj_UI.menu_lift) : 0);

t++;
sfx_now = {};   // play_once's "already played this frame" list

// types out like the textbox: half a letter a frame, a beat after . ? ! and half one after ,
if (text_pause > 0) text_pause--;
else if (text_shown < string_length(text))
{
    var _prev = floor(text_shown);
    text_shown = min(string_length(text), text_shown + type_speed);
    var _n = floor(text_shown);
    if (_n > _prev)
    {
        var _c  = string_char_at(text, _n);
        var _nx = string_char_at(text, _n + 1);
        if ((_c == "." || _c == "?" || _c == "!") && (_nx == " " || _nx == "" || _nx == "\n")) text_pause = text_pause_time;
        else if (_c == ",") text_pause = text_pause_time / 2;
    }
}

// whoever the cursor's on flashes
with (obj_battle_titanspawn) targeted = false;
if (mode == "enemy" && (state == "choose"))
{
    var _e = enemies();
    if (pick_i < array_length(_e)) _e[pick_i].targeted = true;
}

switch (state)
{
    // ---------------------------------------------------------------- a new turn
    case "turn_start":
    {
		global.soul_glow_radius = 48;   // Brighten only lasts the turn it's used
        // anyone DOWN gets a bit back (Deltarune)
        var _down = false;
        with (obj_battle_ui_box) if (hp <= 0) _down = true;
        if (_down) scr_party_turn_recover();

        actions = array_create(3, undefined);
        with (obj_battle_ui_box) defending = false;
        for (var i = 0; i < 3; i++) if (alive_member(i)) scr_bm_idle(defs[i]);

        set_text(flavor[irandom(array_length(flavor) - 1)]);
        var _first = next_chooser(0);
        if (_first == -1) { state = "enemy_turn"; t = 0; break; }   // nobody can act
        begin_choosing(_first);
        state = "choose";
        t = 0;
    }
    break;

    // ---------------------------------------------------------------- picking
    case "choose":
    {
        if (t < 2) break;   // so the Z that got us here doesn't count twice
        var _d = defs[chooser];

        switch (mode)
        {
            case "cmd":
            {
                var _n = array_length(_d.cmds);
                if (keyboard_check_pressed(vk_left))  { cmd_i[chooser] = (cmd_i[chooser] + _n - 1) mod _n; snd_move(); }
                if (keyboard_check_pressed(vk_right)) { cmd_i[chooser] = (cmd_i[chooser] + 1) mod _n; snd_move(); }
                if (key_back())
                {
                    var _p = prev_chooser(chooser);
                    if (_p != -1) { undo(_p); begin_choosing(_p); snd_move(); t = 0; }
                    break;
                }
                if (!key_ok()) break;

                switch (_d.cmds[cmd_i[chooser]])
                {
                    // pressing the button puts them in its ready straight away (X back out of it and they're idle again)
                    case "FIGHT":  ready_pose(chooser, "fight"); pending = "fight"; mode = "enemy"; pick_i = 0; snd_ok(); break;
                    case "SPARE":  ready_pose(chooser, "spare"); pending = "spare"; mode = "enemy"; pick_i = 0; snd_ok(); break;
                    case "MAGIC":  ready_pose(chooser, "spell"); list = _d.magic; list_i = 0; mode = "list"; snd_ok(); break;
                    case "ACT":    ready_pose(chooser, "act");   list = _d.magic; list_i = 0; mode = "list"; snd_ok(); break;
                    case "ITEM":
                        if (array_length(items) == 0) { snd_no(); break; }
                        ready_pose(chooser, "item"); list = items; list_i = 0; mode = "list"; snd_ok();
                    break;
                    case "DEFEND":
                    {
                        var _gain = global.tp.dark ? global.tp.defend_gain_dark : global.tp.defend_gain;
                        scr_tp_defend(1);
                        members[chooser].defending = true;
                        commit({ kind: "defend", tp_gain: _gain, phase: 0, t: 0 });
                    }
                    break;
                }
                t = 0;
            }
            break;

            case "list":
            {
                var _n = array_length(list);
                if (keyboard_check_pressed(vk_right) && list_i + 1 < _n && (list_i mod 2) == 0) { list_i++; snd_move(); }
                if (keyboard_check_pressed(vk_left)  && (list_i mod 2) == 1) { list_i--; snd_move(); }
                if (keyboard_check_pressed(vk_down)  && list_i + 2 < _n) { list_i += 2; snd_move(); }
                if (keyboard_check_pressed(vk_up)    && list_i - 2 >= 0) { list_i -= 2; snd_move(); }
                if (key_back()) { mode = "cmd"; scr_bm_idle(_d); snd_move(); t = 0; break; }
                if (!key_ok()) break;

                var _o = list[list_i];
                var _is_item = (list == items);
                if (!_is_item && _o.tp > global.tp.value) { snd_no(); break; }
                pending = _o;
                pick_i = 0;
                if (_o.target == "enemy") { mode = "enemy"; snd_ok(); }
                else if (_o.target == "ally") { mode = "ally"; snd_ok(); }
                else
                {
                    // no target to pick: it's locked in
                    if (_is_item) { array_delete(items, list_i, 1); commit({ kind: "item", item: _o, slot: list_i, target: noone, phase: 0, t: 0 }); }
                    else { scr_tp_spend(_o.tp); commit({ kind: (_d.cmds[1] == "ACT") ? "act" : "spell", spell: _o, target: noone, phase: 0, t: 0 }); }
                }
                t = 0;
            }
            break;

            case "enemy":
            {
                var _e = enemies();
                var _n = array_length(_e);
                if (_n == 0) { mode = "cmd"; break; }
                pick_i = min(pick_i, _n - 1);
                if (keyboard_check_pressed(vk_down)) { pick_i = (pick_i + 1) mod _n; snd_move(); }
                if (keyboard_check_pressed(vk_up))   { pick_i = (pick_i + _n - 1) mod _n; snd_move(); }
                if (key_back())
                {
                    if (is_struct(pending)) mode = "list";            // back to the spell / ACT list: still in its ready
                    else { mode = "cmd"; scr_bm_idle(_d); }           // back to the buttons: idle again
                    snd_move(); t = 0; break;
                }
                if (!key_ok()) break;

                var _tg = _e[pick_i];
                if (pending == "fight")      commit({ kind: "fight", target: _tg, phase: 0, t: 0 });
                else if (pending == "spare") commit({ kind: "spare", target: _tg, phase: 0, t: 0 });
                else
                {
                    scr_tp_spend(pending.tp);
                    commit({ kind: (_d.cmds[1] == "ACT") ? "act" : "spell", spell: pending, target: _tg, phase: 0, t: 0 });
                }
                t = 0;
            }
            break;

            case "ally":
            {
                if (keyboard_check_pressed(vk_down)) { pick_i = (pick_i + 1) mod 3; snd_move(); }
                if (keyboard_check_pressed(vk_up))   { pick_i = (pick_i + 2) mod 3; snd_move(); }
                if (key_back()) { mode = "list"; snd_move(); t = 0; break; }
                if (!key_ok()) break;

                var _box = members[pick_i];
                if (_box == noone) { snd_no(); break; }
                if (list == items)
                {
                    array_delete(items, list_i, 1);
                    commit({ kind: "item", item: pending, slot: list_i, target: _box, phase: 0, t: 0 });
                }
                else
                {
                    scr_tp_spend(pending.tp);
                    commit({ kind: "spell", spell: pending, target: _box, phase: 0, t: 0 });
                }
                t = 0;
            }
            break;
        }
    }
    break;

    // ---------------------------------------------------------------- playing it all out
    case "exec_next":
        if (array_length(queue) > 0)
        {
            cur = queue[0];
            array_delete(queue, 0, 1);
            if (cur.kind == "act") cur.kind = "spell";   // ACTs run the same way as spells
            state = "exec_run";
        }
        else if (array_length(fighters) > 0) { set_text(""); state = "fight"; t = 0; }
        else { state = "enemy_check"; t = 0; }
    break;

    case "exec_run":
        if (run_action(cur)) { cur = undefined; state = "exec_next"; }
    break;

    // FIGHT: every fighter's cursor slides left on its own. Z hits the leftmost one that's close enough:
    // it stops, flashes, and that person attacks right away (the others keep coming). one that slides past is a MISS
    // FIGHT: every fighter's bolt slides left at once. Z hits the closest one (and any on the exact same spot):
    // it bursts and that person attacks right away (the others keep coming). one that slides past is a MISS
    case "fight":
    {
        var _all_done = true, _any_moving = false;
        fb_flash = max(0, fb_flash - 0.1);

        // Z (Deltarune's rules): of the bolts between 15 steps before the target and 5 after, the closest one
        // goes, along with any other bolt that's exactly as close (bolts that came in on the same spot)
        if (t > 1 && key_ok())
        {
            fb_flash = 1;
            var _closest = infinity;
            for (var i = 0; i < array_length(fighters); i++)
            {
                var _f = fighters[i];
                if (_f.phase != "move") continue;
                var _c = round((_f.x - fb_target_x) / fb_step);
                if (_c < fb_hit_far && _c > -fb_hit_late) _closest = min(_closest, _c);
            }
            if (_closest != infinity) for (var i = 0; i < array_length(fighters); i++)
            {
                var _f = fighters[i];
                if (_f.phase != "move" || round((_f.x - fb_target_x) / fb_step) != _closest) continue;
                var _d  = defs[_f.who];
                var _fc = fb_cols[$ names[_f.who]];
                var _p  = abs(_closest);
                _f.close  = _closest;
                _f.x      = fb_target_x + _closest * fb_step;   // it snaps onto its step
                _f.crit   = (_p == 0);
                _f.points = _f.crit ? crit_points : (_p == 1 ? 120 : (_p == 2 ? 110 : 100 - _p * 2));
                _f.col    = _f.crit ? col_yellow : (_p < 15 ? _fc.dmg : _fc.target);
                _f.phase  = "attack";
                _f.t      = 0;
                _f.scale  = 1;
                _f.alpha  = 1;
                if (_f.crit)
                {
                    play_once(snd_criticalswing);
                    repeat (5) array_push(_f.stars, { x: _f.x, y: 0, vx: random_range(1, 3), vy: random_range(-2.5, 2.5), a: 1 });
                }
                // they swing right now
                scr_bm_pose(_d.obj, _d.attack, true);
                if (_d.attack_sound_frame <= 0) play_once(snd_attack);
            }
        }

        for (var i = 0; i < array_length(fighters); i++)
        {
            var _f = fighters[i];
            var _d = defs[_f.who];
            _f.t++;
            // the hit bolt bursts: grows and fades (faster on a critical)
            if (_f.phase != "move" && _f.phase != "miss" && _f.alpha > 0)
            {
                _f.scale += _f.crit ? 0.1 : 0.05;
                _f.alpha -= 0.05;
            }
            for (var k = array_length(_f.ghosts) - 1; k >= 0; k--)
            {
                _f.ghosts[k].a -= 0.02;
                if (_f.ghosts[k].a <= 0) array_delete(_f.ghosts, k, 1);
            }
            for (var k = array_length(_f.stars) - 1; k >= 0; k--)
            {
                var _st = _f.stars[k];
                _st.x += _st.vx; _st.y += _st.vy; _st.a -= 0.03;
                if (_st.a <= 0) array_delete(_f.stars, k, 1);
            }

            switch (_f.phase)
            {
                case "move":
                    _all_done = false;
                    _any_moving = true;
                    _f.x -= fb_speed;
                    // afterimages, one every 16px it travels (Deltarune's, every 2 of its frames)
                    _f.ghost_d += fb_speed;
                    if (_f.ghost_d >= fb_after_every) { _f.ghost_d -= fb_after_every; array_push(_f.ghosts, { x: _f.x, a: 0.4 }); }
                    if (round((_f.x - fb_target_x) / fb_step) <= fb_miss_at)
                    {
                        // slid past: MISS (no attack)
                        _f.phase = "miss";
                        _f.t = 0;
                        var _tg = retarget(_f.target);
                        if (_tg != noone) scr_trigger_damage_popup(_tg, "MISS", col_grey, col_grey, 0, -sprite_get_yoffset(_tg.sprite_index) * _tg.image_yscale - 4, noone);
                    }
                break;

                case "attack":
                    _all_done = false;
                    if (_d.attack_sound_frame > 0 && !variable_struct_exists(_f, "snd_done") && floor(_d.obj.image_index) >= _d.attack_sound_frame)
                    {
                        _f.snd_done = true;
                        play_once(snd_attack);
                    }
                    // the hit lands as their swing finishes
                    if (_d.obj.image_speed == 0 || _f.t >= 60)
                    {
                        var _tg = retarget(_f.target);
                        if (_tg != noone) _tg.take_hit(max(1, round(_d.at * _f.points / 20 * fight_mult) - _tg.df * 3), _d.color);
                        scr_tp_add(_f.points / (global.tp.dark ? fight_tp_div_dark : fight_tp_div) * 0.4);   // TP (much less in darkness)
                        _f.phase = "after";
                        _f.t = 0;
                    }
                break;

                case "after":   // hold on the swing a moment, then back to idle
                case "miss":
                    _all_done = false;
                    if (_f.t >= 30) { scr_bm_idle(_d); _f.phase = "done"; }
                break;
            }
        }
        // once nothing's moving the rows fade to black, then on to the enemies' turn
        if (!_any_moving) fb_fade = min(1, fb_fade + fb_fade_speed);
        if (_all_done && fb_fade >= 1) { fighters = []; state = "enemy_check"; t = 0; }
    }
    break;

    // ---------------------------------------------------------------- the enemies' turn
    case "enemy_check":
        if (array_length(enemies()) == 0) { set_text("* You won!"); state = "win"; t = 0; }
        else { state = "enemy_turn"; t = 0; }
    break;

    case "enemy_turn":
    {
        set_text("");
        var _r = cur_round();
        if (_r != undefined && variable_struct_exists(_r, "talk") && array_length(_r.talk) > 0)
        {
            talk_chain = instance_create_depth(0, 0, 0, obj_dialogue_chain);
            talk_chain.batches = [ _r.talk ];
            state = "enemy_talk";
        }
        else state = "enemy_attack";
        t = 0;
    }
    break;

    case "enemy_talk":
        if (!instance_exists(obj_dialogue_chain)) { state = "enemy_attack"; t = 0; }
    break;

    case "enemy_attack":
    {
        var _r = cur_round();
        if (_r != undefined && variable_struct_exists(_r, "attack") && _r.attack != undefined)
        {
            with (obj_soul) instance_destroy();
            with (obj_battlebox) instance_destroy();
            box_inst = scr_spawn_battlebox(box_x_nudge);
            box_inst.depth = box_depth;
            // a smaller box, a bit higher up, so there's room underneath it
            with (box_inst)
            {
                target_scale_x = other.box_scale;
                target_scale_y = other.box_scale;
                prev_target_scale_x = target_scale_x;
                prev_target_scale_y = target_scale_y;
                image_xscale = target_scale_x;   // starts at that size instead of shrinking in
                image_yscale = target_scale_y;
                box_base_y  += other.box_y_nudge;
                x = box_base_x + (raw_width  - raw_width  * image_xscale) / 2;
                y = box_base_y + (raw_height - raw_height * image_yscale) / 2;
            }
            state = "enemy_box_open";
        }
        else if (t >= enemy_wait_frames) state = "turn_end";
    }
    break;

    case "enemy_box_open":
        if (instance_exists(box_inst) && box_inst.state == "idle")
        {
            var _r = cur_round();
            atk_inst = _r.attack();
            state = "enemy_box_attack";
        }
    break;

    case "enemy_box_attack":
        if (!instance_exists(atk_inst))
        {
            with (obj_soul) instance_destroy();
            if (instance_exists(box_inst)) box_inst.state = "closing";
            state = "enemy_box_close";
        }
    break;

    case "enemy_box_close":
        if (!instance_exists(box_inst)) { state = "turn_end"; t = 0; }
    break;

    case "turn_end":
        // Queen used her shield this round: it breaks now (like her Chapter 2 shields)
        if (t == 1) scr_queen_shield_break();
        if (t >= 10 && !instance_exists(obj_queen_shield)) { turn++; state = "turn_start"; t = 0; }
    break;

    // ---------------------------------------------------------------- won
    case "win":
        if ((t >= 30 && key_ok()) || t >= 120) end_battle();
    break;

    case "end_wait":
        if (t >= 50)
        {
            with (obj_battle_ui_box) instance_destroy();
            with (obj_UI) instance_destroy();
            with (obj_tp_bar) instance_destroy();
            if (variable_global_exists("music")) audio_stop_sound(global.music);
            if (on_win != undefined) on_win();
            else global.cutscene_lock = false;   // Z opens the next self_ line
            instance_destroy();
        }
    break;
}