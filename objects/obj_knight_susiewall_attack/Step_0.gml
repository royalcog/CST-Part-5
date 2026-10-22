if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

switch (state)
{
    case "intro":
        if (scr_box_scale_settled()) timer--;
        if (timer <= 0) { timer = 0; state = "warm"; }
    break;

    // building up
    case "warm":
        timer--;
        if (timer <= 0 && vi < warm_volleys)
        {
            var _p = vi / max(warm_volleys - 1, 1);
            scr_spawn_lane_volley(round(lerp(warm_swords_a, warm_swords_b, _p)), round(lerp(warm_charge_a, warm_charge_b, _p)));
            timer = round(lerp(warm_gap_a, warm_gap_b, _p));
            vi++;
        }
        if (vi >= warm_volleys && !instance_exists(obj_knight_lane_sword))
        {
            // no Susie, no barrier — skip the volley nobody could survive
            state = scr_party_is_up(obj_susie) ? "big" : "end_wait";
            timer = end_delay;
        }
    break;

    // every lane from both directions
    case "big":
        for (var _lane = 0; _lane < 3; _lane++)
        {
            for (var _side = 0; _side < 4; _side++)
            {
                scr_spawn_lane_sword(_side, _lane, big_charge + irandom(6));
            }
        }
        talk(susie_line);
        big_t = 0;
        timer = buster_delay;
        state = "big_buster";
    break;

    // Susie throws it into a row the soul ISN'T in, so you have to move
    case "big_buster":
        big_t++;
        timer--;
        if (timer <= 0)
        {
            var _L = scr_knight_lanes();
            var _soul_row = instance_exists(obj_soul) ? scr_knight_lane_index(_L.ys, obj_soul.y) : 1;
            var _rows = [];
            for (var r = 0; r < 3; r++) if (r != _soul_row) array_push(_rows, r);
            barrier_row = _rows[irandom(array_length(_rows) - 1)];

            buster = instance_create_depth(0, 0, obj_battlebox.depth - 1, obj_rude_buster);
            buster.break_on_hit = false;
            buster.target_x = _L.cx;
            buster.target_y = _L.ys[barrier_row];
            state = "big_flying";
        }
    break;

    case "big_flying":
        big_t++;
        if (!instance_exists(buster) || buster.landed)
        {
            var _L = scr_knight_lanes();
            var _b = instance_create_depth(0, 0, obj_battlebox.depth - 1, obj_susie_barrier);
            _b.x1 = _L.cx - _L.hx;
            _b.x2 = _L.cx + _L.hx;
            _b.y1 = _L.ys[barrier_row] - _L.hy / 3;
            _b.y2 = _L.ys[barrier_row] + _L.hy / 3;
            _b.hold = max(big_charge - big_t, 0) + barrier_hold;

            audio_play_sound(snd_impact, 1, false);
            scr_camera_shake(3, 10);
            state = "big_fire";
        }
    break;

    case "big_fire":
        if (!instance_exists(obj_knight_lane_sword) && !instance_exists(obj_susie_barrier))
        {
            timer = end_delay;
            state = "end_wait";
        }
    break;

    case "end_wait":
        timer--;
        if (timer <= 0) instance_destroy();
    break;
}