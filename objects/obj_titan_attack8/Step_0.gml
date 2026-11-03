event_inherited();
if (!instance_exists(id)) exit;
if (!ending && instance_exists(obj_battlebox) && t >= beam_start && t < attack_time - beam_stop && (t - beam_start) mod beam_gap == 0)
    titan_beam_add("col", titan_beam_soul_k().x);
titan_beams_step();