t++;
if (text_shown < string_length(text)) text_shown = min(string_length(text), text_shown + type_speed);

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
                    case "FIGHT":  pending = "fight"; mode = "enemy"; pick_i = 0; snd_ok(); break;
                    case "SPARE":  pending = "spare"; mode = "enemy"; pick_i = 0; snd_ok(); break;
                    case "MAGIC":
                    case "ACT":    list = _d.magic; list_i = 0; mode = "list"; snd_ok(); break;
                    case "ITEM":
                        if (array_length(items) == 0) { snd_no(); break; }
                        list = items; list_i = 0; mode = "list"; snd_ok();
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
                if (key_back()) { mode = "cmd"; snd_move(); t = 0; break; }
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
                if (key_back()) { mode = is_struct(pending) ? "list" : "cmd"; snd_move(); t = 0; break; }
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
        else if (array_length(fighters) > 0) { set_text(""); state = "fight_bars"; t = 0; }
        else { state = "enemy_check"; t = 0; }
    break;

    case "exec_run":
        if (run_action(cur)) { cur = undefined; state = "exec_next"; }
    break;

    // the timing bars: Z hits the front-most one still moving
    case "fight_bars":
    {
        var _left = 0;
        for (var i = 0; i < array_length(fighters); i++)
        {
            var _f = fighters[i];
            _f.flash = max(0, _f.flash - 0.1);
            if (_f.done) continue;
            _f.x -= bar_speed;
            if (_f.x < bar_x0 - miss_after) { _f.done = true; _f.points = 0; }   // missed it
            else _left++;
        }
        if (t > 2 && key_ok())
        {
            var _best = -1;
            for (var i = 0; i < array_length(fighters); i++)
                if (!fighters[i].done && (_best == -1 || fighters[i].x < fighters[_best].x)) _best = i;
            if (_best != -1)
            {
                var _f = fighters[_best];
                var _dist = abs(_f.x - bar_x0);
                _f.crit   = _dist <= crit_window;
                _f.points = _f.crit ? 150 : max(0, round(110 - _dist * 2.2));
                _f.done   = true;
                _f.flash  = 1;
                audio_play_sound(snd_select, 1, false, 0.6, 0, _f.crit ? 1.4 : 1);
            }
        }
        if (_left == 0) { state = "fight_wait"; t = 0; }
    }
    break;

    case "fight_wait":
        if (t >= 15) { fight_i = 0; state = "fight_hit"; t = 0; }
    break;

    // each fighter swings in turn, the hit lands when their animation finishes
    case "fight_hit":
    {
        if (fight_i >= array_length(fighters)) { fighters = []; state = "enemy_check"; t = 0; break; }
        var _f = fighters[fight_i];
        var _d = defs[_f.who];
        if (t == 1)
        {
            scr_bm_pose(_d.obj, _d.attack, true);
            if (_d.attack_sound_frame <= 0) audio_play_sound(snd_attack, 1, false);
        }
        if (t > 1 && _d.attack_sound_frame > 0 && floor(_d.obj.image_index) == _d.attack_sound_frame && !variable_struct_exists(_f, "snd_done"))
        {
            _f.snd_done = true;
            audio_play_sound(snd_attack, 1, false);
        }
        if (t > 1 && !variable_struct_exists(_f, "hit_done") && (_d.obj.image_speed == 0 || t >= 60))
        {
            _f.hit_done = true;
            var _tg = retarget(_f.target);
            if (_tg != noone)
            {
                if (_f.points <= 0) scr_trigger_damage_popup(_tg, "MISS", col_grey, col_grey, 0, -sprite_get_yoffset(_tg.sprite_index) * _tg.image_yscale - 4, noone);
                else
                {
                    var _dmg = round(_d.fight_base * _f.points / 100 * random_range(0.9, 1.1));
                    _tg.take_hit(_dmg, _d.color);
                }
            }
            // TP from the hit (much less in darkness)
            scr_tp_add(_f.points / (global.tp.dark ? fight_tp_div_dark : fight_tp_div) * 0.4);
            t = 2;
            _f.wait = 30;
        }
        if (variable_struct_exists(_f, "hit_done"))
        {
            _f.wait--;
            if (_f.wait <= 0) { scr_bm_idle(_d); fight_i++; t = 0; }
        }
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
        var _r = (array_length(rounds) > 0) ? rounds[turn mod array_length(rounds)] : undefined;
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
        var _r = (array_length(rounds) > 0) ? rounds[turn mod array_length(rounds)] : undefined;
        if (_r != undefined && variable_struct_exists(_r, "attack") && _r.attack != undefined)
        {
            with (obj_soul) instance_destroy();
            with (obj_battlebox) instance_destroy();
            box_inst = scr_spawn_battlebox(box_x_nudge);
            box_inst.depth = box_depth;
            state = "enemy_box_open";
        }
        else if (t >= enemy_wait_frames) state = "turn_end";
    }
    break;

    case "enemy_box_open":
        if (instance_exists(box_inst) && box_inst.state == "idle")
        {
            var _r = rounds[turn mod array_length(rounds)];
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
        if (t >= 10) { turn++; state = "turn_start"; t = 0; }
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