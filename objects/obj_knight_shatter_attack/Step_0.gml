if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

scr_slashes_step();
push_blocked(); // keeps a fresh soul up to date too

for (var i = 0; i < 9; i++) if (cells[i].broken) cells[i].t++;
if (restore_t > 0) restore_t--;

for (var i = array_length(shards) - 1; i >= 0; i--)
{
    var _p = shards[i];
    _p.vy  += shard_gravity;
    _p.x   += _p.vx;
    _p.y   += _p.vy;
    _p.rot += _p.vr;
    _p.life--;
    if (_p.life <= 0) array_delete(shards, i, 1);
}

switch (state)
{
    case "intro":
        if (scr_box_scale_settled()) timer--;
        if (timer <= 0)
        {
            // this one's built on the grid
            var _s = get_soul();
            if (instance_exists(_s) && _s.soul_mode != "lightblue") scr_soul_set_mode(_s, "lightblue");
            vi = 0;
            timer = 0;
            state = "break";
        }
    break;

    // the Knight's cuts shatter the grid bit by bit
    case "break":
        timer--;
        if (timer <= 0 && vi < break_volleys)
        {
            var _p = vi / max(break_volleys - 1, 1);
            spawn_volley(round(lerp(break_lines_a, break_lines_b, _p)), round(lerp(break_charge_a, break_charge_b, _p)), true);
            timer = round(lerp(break_gap_a, break_gap_b, _p));
            vi++;
        }
        if (vi >= break_volleys && array_length(slashes) == 0)
        {
            // no Susie, no fix — it just ends on the broken grid
            if (scr_party_is_up(obj_susie)) { chain = talk(susie_line); timer = buster_delay; state = "susie"; }
            else { timer = end_delay; state = "end_wait"; }
        }
    break;

    case "susie":
        timer--;
        if (timer <= 0)
        {
            var _c = scr_box_center();
            buster = instance_create_depth(0, 0, obj_battlebox.depth - 1, obj_rude_buster);
            buster.break_on_hit = false; // fixes the grid instead of breaking the box
            buster.target_x = _c.x;
            buster.target_y = _c.y;
            state = "buster";
        }
    break;

    // Rude Buster lands -> every sector comes back
    case "buster":
        if (!instance_exists(buster) || buster.landed)
        {
            for (var i = 0; i < 9; i++) { cells[i].broken = false; cells[i].t = 0; }
            push_blocked();
            restore_t = restore_frames;
            if (restore_sound != noone) audio_play_sound(restore_sound, 1, false, 1.5);
            audio_play_sound(snd_impact, 1, false);
            scr_camera_shake(3, 10);
            timer = finale_delay;
            state = "finale_wait";
        }
    break;

    case "finale_wait":
        timer--;
        if (timer <= 0 && !instance_exists(chain)) { vi = 0; timer = 0; state = "finale"; }
    break;

    case "finale":
        timer--;
        if (timer <= 0 && vi < finale_volleys)
        {
            var _p = vi / max(finale_volleys - 1, 1);
            spawn_volley(round(lerp(finale_lines_a, finale_lines_b, _p)), finale_charge, false);
            timer = finale_gap;
            vi++;
        }
        if (vi >= finale_volleys && array_length(slashes) == 0)
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