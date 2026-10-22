if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
var _bb = obj_battlebox;

// the box (and the soul's section with it) turning
if (turn_t >= 0)
{
    turn_t++;
    var _k = clamp(turn_t / turn_frames, 0, 1);
    _k = _k * _k * (3 - 2 * _k);
    _bb.box_angle = lerp(turn_from, turn_to, _k);
    if (turn_t >= turn_frames) { _bb.box_angle = turn_to; turn_t = -1; }
}

switch (state)
{
    case "intro":
        if (scr_box_scale_settled()) timer--;
        if (timer <= 0) state = "volley";
    break;

    case "volley":
        var _p = vi / max(array_length(volleys) - 1, 1);
        charge = round(lerp(charge_a, charge_b, _p));
        scr_spawn_lane_volley(volleys[vi], charge); // locks onto the lanes as they are right now
        t = 0;
        turned = false;
        state = "charging";
    break;

    case "charging":
        t++;
        if (!turned && t >= charge * turn_at)
        {
            turned = true;
            start_turn(choose(-90, 90)); // the soul gets carried somewhere new before they fire
        }
        if (t > charge && turn_t < 0 && !instance_exists(obj_knight_lane_sword))
        {
            vi++;
            if (vi >= array_length(volleys)) state = unwind ? "unwind" : "done";
            else { timer = volley_gap; state = "gap"; }
        }
    break;

    case "gap":
        timer--;
        if (timer <= 0) state = "volley";
    break;

    case "unwind":
        var _back = angle_difference(0, _bb.box_angle);
        if (abs(_back) > 1) start_turn(_back);
        state = "unwinding";
    break;

    case "unwinding":
        if (turn_t < 0) { _bb.box_angle = 0; state = "done"; }
    break;

    case "done":
        instance_destroy();
    break;
}