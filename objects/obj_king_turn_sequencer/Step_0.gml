// both party members down: end the battle right here, whatever's happening
if (end_on_party_wipe && state != "party_wiped" && scr_party_all_down())
{
    scr_battle_wipe_cleanup();
    timer = wipe_hold;
    state = "party_wiped";
}

var _round = (round_index >= 0 && round_index < array_length(rounds)) ? rounds[round_index] : noone;

switch (state)
{
    // wait for obj_UI to finish sliding into position, then hold a beat before starting
    case "waiting_ui_settle":
        if (instance_exists(obj_UI) && abs(obj_UI.x - obj_UI.target_x) < 1)
        {
            timer--;
            if (timer <= 0)
            {
                state = "advance_round";
            }
        }
    break;

    case "advance_round":
        if (array_length(rounds) == 0) break; // nothing configured yet — idle

        round_index = (round_index + 1) mod array_length(rounds);
        _round = rounds[round_index];
		
		// a round with skip_party goes straight to its dialogue: no readies, no attacks
        if (variable_struct_exists(_round, "skip_party") && _round.skip_party)
        {
            if (instance_exists(obj_UI)) obj_UI.active_box = noone;
            state = "talk_start";
            break;
        }

        // dialogue-only: skip readies and attacks completely
        if (dialogue_only)
        {
            if (instance_exists(obj_UI)) obj_UI.active_box = noone;
            state = "talk_start";
            break;
        }

        // reset every box back to its normal look for the new round
        with (obj_battle_ui_box)
        {
            selected_attack = false;
        }

        // downed members recover a bit each turn (and get back up once above 0)
        scr_party_turn_recover();

        select_index = next_alive(0);
        if (select_index < array_length(members))
        {
            if (members[select_index] != noone) obj_UI.active_box = members[select_index];
            timer = select_hold_frames;
            state = "select_active";
        }
        else
        {
            // nobody can act this turn
            obj_UI.active_box = noone;
            attack_index = 0;
            state = "attacking_start";
        }
    break;

    // Susie's box turns from normal -> attack, then Ralsei's, then Queen's — one at a time.
    // The highlighted pose shows while that box is still active, so it's actually visible.
    case "select_active":
        timer--;
        if (timer <= 0)
        {
            if (select_index < array_length(members) && members[select_index] != noone)
            {
                var _box = members[select_index];

                // hold Susie/Ralsei in their "ready" stance until their attack turn actually comes up.
                // normally this data comes from _round.attackers, but a round with no real attacks
                // (e.g. the final round, cut off by Lancer) can supply ready_poses instead so the
                // party still visibly readies up even though nothing actually attacks.
                var _pose_list = (_round != noone && variable_struct_exists(_round, "ready_poses"))
                    ? _round.ready_poses
                    : (_round != noone ? _round.attackers : []);
                var _picked = (select_index < array_length(_pose_list)) ? _pose_list[select_index] : undefined;

                // box art for what they picked: the round can swap it (e.g. SPELL), otherwise their normal FIGHT art
                if (!variable_instance_exists(_box, "base_attack_frame")) _box.base_attack_frame = _box.attack_frame;
                _box.attack_frame = (_picked != undefined && variable_struct_exists(_picked, "attack_frame"))
                    ? _picked.attack_frame
                    : _box.base_attack_frame;

                _box.selected_attack = true;
                audio_play_sound(snd_select, 1, false);

                if (_picked != undefined && variable_struct_exists(_picked, "attacker") && variable_struct_exists(_picked, "ready_sprite") && instance_exists(_picked.attacker))
                {
                    var _hold = variable_struct_exists(_picked, "ready_hold") && _picked.ready_hold;
                    with (_picked.attacker)
                    {
                        sprite_index = _picked.ready_sprite;
                        image_index = 0;
                        image_speed = _hold ? 0 : 1;
                        anim_loop = true;
                    }
                }
            }
            timer = select_confirm_frames;
            state = "select_confirm";
        }
    break;

    case "select_confirm":
        timer--;
        if (timer <= 0)
        {
            select_index = next_alive(select_index + 1); // skips anyone who's down

            if (select_index < array_length(members))
            {
                if (members[select_index] != noone) obj_UI.active_box = members[select_index];
                timer = select_hold_frames;
                state = "select_active";
            }
            else
            {
                obj_UI.active_box = noone; // everyone's chosen — no box stays raised
                attack_index = 0;
                state = "attacking_start";
            }
        }
    break;
	
	case "party_wiped":
        timer--;
        if (timer <= 0)
        {
            if (global.music != noone) audio_stop_sound(global.music);
            global.music = noone;
            global.song  = noone;
            if (on_party_wipe != noone) on_party_wipe();
            instance_destroy();
        }
    break;

    // attack animations play one at a time, each dealing its own damage to King
    case "attacking_start":
        if (attack_index >= array_length(_round.attackers))
        {
            state = (_round != noone && variable_struct_exists(_round, "is_final") && _round.is_final)
                ? "final_dialogue_start" : "talk_start";
            break;
        }
		
		// swooned members don't attack
        if (member_down(attack_index))
        {
            attack_index++;
            break;
        }

        var _atk = _round.attackers[attack_index];
        // a line before this attacker goes (e.g. Ralsei: "Let's try this...")
        if (variable_struct_exists(_atk, "pre_talk") && !pre_talk_done)
        {
            pre_talk_done  = true;
            pre_talk_chain = instance_create_depth(0, 0, 0, obj_dialogue_chain);
            pre_talk_chain.batches = [ _atk.pre_talk ];
            state = "attacking_pre_talk";
            break;
        }
        pre_talk_done = false;
        attack_sound_played = false;

        var _has_anim = variable_struct_exists(_atk, "attacker") && variable_struct_exists(_atk, "attack_sprite")
            && instance_exists(_atk.attacker);

        if (_has_anim)
        {
            with (_atk.attacker)
            {
                sprite_index = _atk.attack_sprite;
                image_index = 0;
                image_speed = 1;
                anim_loop = false;
            }

            // no delay frame set — play right as the swing starts, same as before
            var _sound_frame = variable_struct_exists(_atk, "attack_sound_frame") ? _atk.attack_sound_frame : 0;
            if (_sound_frame <= 0 && variable_struct_exists(_atk, "attack_sound"))
            {
                audio_play_sound(_atk.attack_sound, 1, false);
                attack_sound_played = true;
            }

            state = "attacking_anim_wait";
        }
        else
        {
            if (variable_struct_exists(_atk, "attack_sound"))
            {
                audio_play_sound(_atk.attack_sound, 1, false);
            }
            state = "attacking_hit";
        }
    break;
	
	case "attacking_pre_talk":
        if (!instance_exists(pre_talk_chain)) state = "attacking_start";
    break;

    case "attacking_anim_wait":
        var _atk = _round.attackers[attack_index];

        // fire the swing sound once the animation reaches its configured frame (default: frame 0, already handled above)
        if (!attack_sound_played && variable_struct_exists(_atk, "attack_sound") && instance_exists(_atk.attacker))
        {
            var _sound_frame = variable_struct_exists(_atk, "attack_sound_frame") ? _atk.attack_sound_frame : 0;
            if (_atk.attacker.image_index >= _sound_frame)
            {
                audio_play_sound(_atk.attack_sound, 1, false);
                attack_sound_played = true;
            }
        }

        if (!instance_exists(_atk.attacker) || _atk.attacker.image_speed == 0)
        {
            state = "attacking_hit";
        }
    break;

    case "attacking_hit":
        var _atk = _round.attackers[attack_index];
        var _dmg = _atk.damage;

        // Susie hits twice as hard once she's taken in the soul (Knight attack 4)
        if (is_real(_dmg) && variable_global_exists("susie_soul") && global.susie_soul
            && variable_struct_exists(_atk, "box_name") && _atk.box_name == "Susie")
        {
            _dmg *= 2;
        }

            attack_popup = damage_func(_dmg,
            variable_struct_exists(_atk, "color_top")    ? _atk.color_top    : c_white,
            variable_struct_exists(_atk, "color_bottom") ? _atk.color_bottom : c_white);
        timer = popup_clear_frames; // fallback in case the popup never spawned (e.g. King missing)
        state = "attacking_popup_wait";
    break;

    // hold until the damage number over King has fully faded before this character stands down
    case "attacking_popup_wait":
        var _atk = _round.attackers[attack_index];
        if (attack_popup != noone)
        {
            if (!instance_exists(attack_popup))
            {
                timer = variable_struct_exists(_atk, "post_attack_hold_frames") ? _atk.post_attack_hold_frames : 0;
                state = "attacking_post_hold";
            }
        }
        else
        {
            timer--;
            if (timer <= 0)
            {
                timer = variable_struct_exists(_atk, "post_attack_hold_frames") ? _atk.post_attack_hold_frames : 0;
                state = "attacking_post_hold";
            }
        }
    break;

    // optional extra pause on the attacker's last attack frame before reverting to idle
    // (post_attack_hold_frames on the attacker struct; not set = no extra wait, same as before)
    case "attacking_post_hold":
        timer--;
        if (timer <= 0)
        {
            state = "attacking_revert";
        }
    break;

    case "attacking_revert":
	    var _atk = _round.attackers[attack_index];
	    if (variable_struct_exists(_atk, "attacker") && variable_struct_exists(_atk, "idle_sprite") && instance_exists(_atk.attacker))
	    {
	        var _hold = variable_struct_exists(_atk, "idle_hold") && _atk.idle_hold;
	        with (_atk.attacker)
	        {
	            sprite_index = _atk.idle_sprite;
	            image_index = 0;
	            image_speed = _hold ? 0 : 1;
	            anim_loop = true;
	        }
	    }

	    // this character's own attack is done — drop their box back to inactive
	    // (lowered, normal art) instead of staying raised for the rest of the round
	    if (attack_index < array_length(members) && members[attack_index] != noone)
	    {
	        members[attack_index].selected_attack = false;
	    }

	    attack_index++;
	    timer = attack_settle_frames;
	    state = "attacking_between";
	break;

    case "attacking_between":
        timer--;
        if (timer <= 0)
        {
            state = "attacking_start";
        }
    break;

    case "talk_start":
	    if (_round != noone && array_length(_round.dialogue_batch) > 0)
	    {
	        var _chain = instance_create_depth(0, 0, 0, obj_dialogue_chain);
	        _chain.batches = [ _round.dialogue_batch ];
	        state = "talk_wait";
	    }
	    else
	    {
	        state = dialogue_only ? "dialogue_only_next" : "king_attack_start";
	    }
	break;

	case "talk_wait":
	    if (!instance_exists(obj_dialogue_chain))
	    {
	        state = dialogue_only ? "dialogue_only_next" : "king_attack_start";
	    }
	break;

	// dialogue-only: next round's dialogue if there is one, otherwise fade out of the fight
	case "dialogue_only_next":
	    if (round_index < array_length(rounds) - 1)
	    {
	        timer = 30;
	        state = "king_attack_wait"; // short gap, then advance_round
	    }
	    else
	    {
	        timer = end_warp_hold;
	        state = "end_warp_hold";
	    }
	break;

	case "end_warp_hold":
	    timer--;
	    if (timer <= 0)
	    {
	        if (end_warp_room == noone)
	        {
	            state = end_stop_battle ? "stop_battle" : "battle_end";
	            break;
	        }
	        if (on_end_warp != noone) on_end_warp();
	        // above the TALKbox (-9999) and the UI so everything goes black together
	        var _fader = instance_create_depth(0, 0, -10004, obj_cutscenefade);
	        _fader.fade_target = 1;
	        _fader.target_room = end_warp_room;
	        _fader.wait_duration = end_warp_wait;
	        _fader.new_music_sound = end_warp_song;
	        state = "end_warp_wait";
	    }
	break;

	// nothing to do: the room change destroys this sequencer (it's not persistent)
	case "end_warp_wait":
	
	break;

	// battle gets stopped where it stands: UI slides off, music fades, sprites swap back
	case "stop_battle":
	    scr_ui_hide();
	    if (global.music != noone) audio_sound_gain(global.music, 0, stop_music_fade_ms);
	    for (var i = 0; i < array_length(end_revert); i++)
	    {
	        scr_set_sprite_keep_body(end_revert[i].obj, end_revert[i].sprite);
	    }
	    timer = stop_battle_frames;
	    state = "stop_battle_wait";
	break;

	case "stop_battle_wait":
	    timer--;
	    if (timer <= 0)
	    {
	        if (global.music != noone) audio_stop_sound(global.music);
	        global.music = noone;
	        global.song  = noone; // so start_battle_music() works again next fight
	        with (obj_battle_ui_box) instance_destroy();
	        with (obj_UI) instance_destroy();
	        state = "battle_end"; // sequencer goes away -> Z works again for the next self_ line
	    }
	break;

	// spawns the real barrage if this round has one configured; otherwise
	// falls back to the old fixed-length placeholder gap
		case "king_attack_start":
			if (_round != noone && variable_struct_exists(_round, "king_box_attack"))
		    {
		        if (hide_ui_during_box_attack) scr_ui_slide_down();
		        with (obj_soul) instance_destroy();
		        with (obj_battlebox) instance_destroy();
		        box_inst = scr_spawn_battlebox(king_box_x_nudge);
		        box_inst.depth = king_box_depth; // soul + spades build their depth off this, so they stay in front too
		        state = "king_box_open_wait";
		    }
		    else if (_round != noone && variable_struct_exists(_round, "king_attack"))
		    {
		        with (obj_barrage_spawner) instance_destroy(); // clear any leftover
		        var _spawner = instance_create_depth(0, 0, 0, obj_barrage_spawner);
		        _spawner.data = _round.king_attack;
		        state = "king_attack_barrage_wait";
		    }
		    else
		    {
		        timer = king_attack_placeholder_frames;
		        state = "king_attack_wait";
		    }
		break;

		case "king_box_open_wait":
		    if (instance_exists(box_inst) && box_inst.state == "idle")
		    {
		        king_attack_inst = _round.king_box_attack();
		        state = "king_box_attack_wait";
		    }
		break;

		case "king_box_attack_wait":
		    if (!instance_exists(king_attack_inst))
		    {
		        with (obj_soul) instance_destroy();
		        if (instance_exists(box_inst)) box_inst.state = "closing";
		        state = "king_box_close_wait";
		    }
		break;

		case "king_box_close_wait":
		    if (!instance_exists(box_inst))
		    {
		        if (hide_ui_during_box_attack) scr_ui_slide_up();
		        timer = king_attack_end_pause_frames;
		        state = "king_attack_wait"; // existing countdown, then advance_round
		    }
		break;

	case "king_attack_barrage_wait":
	    if (!instance_exists(obj_barrage_spawner))
	    {
	        state = "advance_round";
	    }
	break;

	case "king_attack_wait":
	    timer--;
	    if (timer <= 0)
	    {
	        state = "advance_round";
	    }
	break;

	// King's cut-off line — plays like normal battle dialogue, but Lancer interrupts partway through
	case "final_dialogue_start":
	    var _chain = instance_create_depth(0, 0, 0, obj_dialogue_chain);
	    _chain.batches = [ _round.dialogue_batch ];
	    timer = lancer_interrupt_delay_frames;
	    state = "final_dialogue_wait";
	break;

	case "final_dialogue_wait":
	    timer--;
	    if (timer <= 0)
	    {
	        state = "lancer_enter_start"; // this state is what calls scr_dialogue_chain_interrupt()
	    }
	break;

	   case "lancer_enter_start":
       scr_dialogue_chain_interrupt(); // cuts King's line off mid-sentence

       // music cuts out the moment Lancer appears
       audio_stop_sound(global.music);
       global.song = noone;

       // drop every party box back to inactive/normal the moment he shows up
       if (instance_exists(obj_UI)) obj_UI.active_box = noone;
       with (obj_battle_ui_box) selected_attack = false;

       // party members are left on their battle-ready pose here on purpose — not reverted
       // to idle automatically. Do that manually from whichever scr_game_text case needs it.

       lancer_inst = instance_create_depth(lancer_spawn_x, lancer_spawn_y, -2000, obj_lancer);
       lancer_inst.sprite_index = spr_lancer_up; // walking-up pose
       lancer_inst.image_speed = 1;
       lancer_inst.depth = 1; // behind obj_UI/obj_battle_ui_box
       state = "lancer_enter_wait";
   break;

   case "lancer_enter_wait":
       if (instance_exists(lancer_inst))
       {
           lancer_inst.y -= lancer_walk_speed;
           if (lancer_inst.y <= lancer_target_y)
           {
               lancer_inst.y = lancer_target_y;
               state = "lancer_turn";
           }
       }
       else
       {
           state = "battle_end";
       }
   break;

   // he's arrived — turn to face left, sad
   case "lancer_turn":
       if (instance_exists(lancer_inst))
       {
           lancer_inst.sprite_index = spr_lancer_left_sad;
           lancer_inst.image_index = 0;
           lancer_inst.image_speed = 0;
       }
       state = "battle_end";
   break;

   case "battle_end":
       instance_destroy();
   break;
}