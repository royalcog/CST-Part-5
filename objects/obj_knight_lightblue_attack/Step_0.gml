if (flash_t > 0) flash_t--;

switch (state)
{
    case "wait_buster":
        timer--;
        if (timer <= 0)
        {
            if (instance_exists(soul)) soul.external_move = true; // hangs in place once the box is gone
            buster = instance_create_depth(0, 0, depth, obj_rude_buster);
            state = "buster";
        }
    break;

    case "buster":
        if (!instance_exists(buster) || buster.broken)
        {
            timer = taunt_delay;
            state = "taunt_wait";
        }
    break;

    case "taunt_wait":
        timer--;
        if (timer <= 0) { chain = talk(susie_taunt); state = "taunt"; }
    break;

    case "taunt":
        if (!instance_exists(chain)) { timer = shake_delay; state = "pre_shake"; }
    break;

    case "pre_shake":
        timer--;
        if (timer <= 0 && instance_exists(soul))
        {
            shake_x = soul.x;
            shake_y = soul.y;
            if (shake_sound != noone) shake_snd = scr_audio_fade_in(shake_sound, 600, 1, true);
            timer = shake_frames;
            state = "shake";
        }
    break;

    // shakes harder and harder, then turns light blue
    case "shake":
        if (!instance_exists(soul)) { instance_destroy(); exit; }
        timer--;
        var _k = 0.4 + 0.6 * (1 - timer / shake_frames);
        soul.x = shake_x + random_range(-shake_amount, shake_amount) * _k;
        soul.y = shake_y + random_range(-shake_amount, shake_amount) * _k;

        if (timer <= 0)
        {
            soul.x = shake_x;
            soul.y = shake_y;
            if (shake_snd != -1) audio_stop_sound(shake_snd);

            global.soul_mode = "lightblue"; // every soul from here on
            scr_soul_set_mode(soul, "lightblue");
            if (change_sound != noone) audio_play_sound(change_sound, 1, false, change_gain);
            flash_t = change_flash_frames;
            flash_x = shake_x;
            flash_y = shake_y;
            scr_camera_shake(2, 8);

            // only whoever's still standing reacts
            shocked = [];
            if (scr_party_is_up(obj_susie))
            {
                scr_set_battle_sprite(obj_susie, spr_susie_shocked, spr_susie_shocked, false);
                array_push(shocked, { obj: obj_susie, idle: spr_susie_battle_idle });
            }
            if (scr_party_is_up(obj_ralsei))
            {
                scr_set_battle_sprite(obj_ralsei, spr_ralsei_shocked, spr_ralsei_shocked, false);
                array_push(shocked, { obj: obj_ralsei, idle: spr_ralsei_battle_idle });
            }

            timer = reaction_hold;
            state = "react_hold";
        }
    break;

    case "react_hold":
        timer--;
        if (timer <= 0)
        {
            var _lines = [];
            for (var i = 0; i < array_length(susie_react); i++) array_push(_lines, susie_react[i]);

            // everyone who got shocked goes back together once Susie's done talking
            array_push(_lines, { run: method(self, function()
            {
                for (var k = 0; k < array_length(shocked); k++)
                {
                    var _s = shocked[k];
                    if (scr_party_is_up(_s.obj)) scr_set_battle_sprite(_s.obj, _s.idle, _s.idle, true);
                }
            }) });

            chain = talk(_lines);
            state = "react";
        }
    break;

    case "react":
        if (!instance_exists(chain)) { timer = test_delay; state = "test_wait"; }
    break;

    // the box comes back for a test run
    case "test_wait":
        timer--;
        if (timer <= 0)
        {
            var _nudge = instance_exists(obj_king_turn_sequencer) ? obj_king_turn_sequencer.king_box_x_nudge : 0;
            box2 = scr_spawn_battlebox(_nudge);
            if (instance_exists(obj_king_turn_sequencer))
            {
                box2.depth = obj_king_turn_sequencer.king_box_depth;
                obj_king_turn_sequencer.box_inst = box2; // so the sequencer closes this one when we're done
            }
            state = "test_open";
        }
    break;

    case "test_open":
        if (!instance_exists(box2)) { instance_destroy(); exit; }

        // drift back to where the soul starts while the box rises
        if (instance_exists(soul))
        {
            soul.x = lerp(soul.x, box2.x + box2.raw_width / 2, glide_lerp);
            soul.y = lerp(soul.y, box2.y + box2.raw_height / 2, glide_lerp);
        }

        // the box makes a fresh (light blue) soul right there once it's open
        if (box2.state == "idle")
        {
            if (instance_exists(soul)) instance_destroy(soul);
            swords = scr_start_knight_attack1();
            state = "test";
        }
    break;

    case "test":
        if (!instance_exists(swords)) instance_destroy(); // sequencer clears the soul + closes the box
    break;
}