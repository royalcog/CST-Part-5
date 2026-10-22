if (flash_t > 0) flash_t--;
grid_fade = grid_on ? min(grid_fade + 1 / grid_fade_frames, 1) : max(grid_fade - 1 / grid_fade_frames, 0);

// --- slashes: warn -> cut -> gone ---
for (var i = array_length(slashes) - 1; i >= 0; i--)
{
    var _sl = slashes[i];
    _sl.t++;

    if (_sl.state == "warn" && !_sl.swung && _sl.t >= _sl.charge - knight_swing_lead)
    {
        _sl.swung = true;
        knight_swing();
    }

    if (_sl.state == "warn" && _sl.t >= _sl.charge)
    {
        _sl.state = "cut";
        _sl.t = 0;
        if (cut_sound != noone && get_timer() - last_cut_snd > 40000)
        {
            audio_play_sound(cut_sound, 1, false);
            last_cut_snd = get_timer();
        }
    }
    else if (_sl.state == "cut")
    {
        if (_sl.t <= hit_frames && instance_exists(obj_soul) && !obj_soul.invulnerable
            && scr_point_segment_distance(obj_soul.x, obj_soul.y, _sl.x1, _sl.y1, _sl.x2, _sl.y2) <= hit_half_width)
        {
            scr_soul_take_hit(slash_damage, hit_color_top, hit_color_bottom);
        }
        if (_sl.t >= cut_frames) array_delete(slashes, i, 1);
    }
}

// the Knight goes back to normal a bit after his last swing finishes
if (!is_undefined(knight_saved))
{
    var _swing_done = !instance_exists(obj_knight) || obj_knight.sprite_index != knight_attack_sprite || obj_knight.image_speed == 0;
    if (_swing_done)
    {
        knight_return_t--;
        if (knight_return_t <= 0) knight_restore();
    }
}

switch (state)
{
    case "intro":
        if (scr_box_scale_settled()) timer--;
        if (timer <= 0)
        {
            var _s = get_soul();
            if (!instance_exists(_s)) { instance_destroy(); exit; }

            // already red: skip the change
            if (_s.soul_mode == "red") { timer = 20; state = "red_wait"; break; }

            _s.external_move = true;
            shake_x = _s.x;
            shake_y = _s.y;
            if (shake_sound != noone) shake_snd = scr_audio_fade_in(shake_sound, 600, 1, true);
            timer = flip_frames;
            state = "to_red";
        }
    break;

    // light blue -> red, inside the box
    case "to_red":
        var _s = get_soul();
        if (!instance_exists(_s)) { instance_destroy(); exit; }
        timer--;
        var _k = 0.4 + 0.6 * (1 - timer / flip_frames);
        _s.x = shake_x + random_range(-flip_shake, flip_shake) * _k;
        _s.y = shake_y + random_range(-flip_shake, flip_shake) * _k;

        if (timer <= 0)
        {
            _s.x = shake_x;
            _s.y = shake_y;
            if (shake_snd != -1) { audio_stop_sound(shake_snd); shake_snd = -1; }
            scr_soul_set_mode(_s, "red");
            _s.external_move = false;
            flash_at(_s.x, _s.y, red_color);
            timer = 30;
            state = "red_wait";
        }
    break;

    case "red_wait":
        timer--;
        if (timer <= 0) { vi = 0; timer = 0; state = "red"; }
    break;

    case "red":
        timer--;
        var _n = array_length(red_patterns);
        if (timer <= 0 && vi < _n)
        {
            var _p = vi / max(_n - 1, 1);
            spawn_red(red_patterns[vi], round(lerp(red_charge_a, red_charge_b, _p)));
            timer = round(lerp(red_gap_a, red_gap_b, _p));
            vi++;
        }
        if (vi >= _n && array_length(slashes) == 0)
        {
            timer = buster_delay;
            // Susie's down: nobody to break the box, so it stays red and goes straight to the finish
            state = scr_party_is_up(obj_susie) ? "pre_buster" : "finale_wait";
        }
    break;

    case "pre_buster":
        timer--;
        if (timer <= 0)
        {
            var _s = get_soul();
            if (instance_exists(_s)) _s.external_move = true; // hangs in place once the box is gone
            buster = instance_create_depth(0, 0, depth, obj_rude_buster);
            state = "buster";
        }
    break;

    // box breaks -> the soul turns light blue and the whole screen is the grid
    case "buster":
        if (!instance_exists(buster) || buster.broken)
        {
            var _s = get_soul();
            if (!instance_exists(_s)) { instance_destroy(); exit; }
            global.soul_mode = "lightblue";
            scr_soul_set_mode(_s, "lightblue"); // also puts it on the middle sector
            _s.external_move = false;
            flash_at(_s.x, _s.y, blue_color);
            grid_on = true;
            timer = blue_start_delay;
            state = "blue_wait";
        }
    break;

    case "blue_wait":
        timer--;
        if (timer <= 0) { vi = 0; timer = 0; followup = false; state = "blue"; }
    break;

    case "blue":
        timer--;

        // the quick second volley lands the moment the first one cuts
        if (followup && array_length(slashes) > 0 && slashes[0].state == "cut")
        {
            spawn_blue(1, followup_charge);
            followup = false;
        }

        if (timer <= 0 && vi < blue_volleys)
        {
            var _p = vi / max(blue_volleys - 1, 1);
            spawn_blue(round(lerp(blue_lines_a, blue_lines_b, _p)), round(lerp(blue_charge_a, blue_charge_b, _p)));
            followup = (vi >= blue_followup_at);
            timer = round(lerp(blue_gap_a, blue_gap_b, _p)) + (followup ? followup_charge : 0);
            vi++;
        }
        if (vi >= blue_volleys && !followup && array_length(slashes) == 0)
        {
            timer = return_delay;
            state = "return_wait";
        }
    break;

    // the box comes back, and the soul goes back to red inside it
    case "return_wait":
        timer--;
        if (timer <= 0)
        {
            grid_on = false;
            var _s = get_soul();
            if (instance_exists(_s)) _s.external_move = true;
            global.soul_mode = "red"; // the box's fresh soul comes out red

            var _nudge = instance_exists(obj_king_turn_sequencer) ? obj_king_turn_sequencer.king_box_x_nudge : 0;
            box2 = scr_spawn_battlebox(_nudge);
            if (instance_exists(obj_king_turn_sequencer))
            {
                box2.depth = obj_king_turn_sequencer.king_box_depth;
                obj_king_turn_sequencer.box_inst = box2; // so the sequencer closes this one when we're done
            }
            state = "return_open";
        }
    break;

    case "return_open":
        if (!instance_exists(box2)) { instance_destroy(); exit; }

        var _old = noone;
        with (obj_soul) if (external_move) _old = id;

        // drift to the middle while the box rises
        if (instance_exists(_old))
        {
            _old.x = lerp(_old.x, box2.x + box2.raw_width / 2, glide_lerp);
            _old.y = lerp(_old.y, box2.y + box2.raw_height / 2, glide_lerp);
        }

        if (box2.state == "idle")
        {
            if (instance_exists(_old)) instance_destroy(_old); // the box already made a fresh red one
            var _s = get_soul();
            if (instance_exists(_s)) flash_at(_s.x, _s.y, red_color);
            timer = 30;
            state = "finale_wait";
        }
    break;

    case "finale_wait":
        timer--;
        if (timer <= 0) { vi = 0; timer = 0; state = "finale"; }
    break;

    case "finale":
        if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
        timer--;
        var _n = array_length(finale_patterns);
        if (timer <= 0 && vi < _n)
        {
            spawn_red(finale_patterns[vi], finale_charge);
            timer = finale_gap;
            vi++;
        }
        if (vi >= _n && array_length(slashes) == 0)
        {
            timer = end_delay;
            state = "end_wait";
        }
    break;

    case "end_wait":
        timer--;
        if (timer <= 0) instance_destroy(); // sequencer clears the soul + closes the box
    break;
}