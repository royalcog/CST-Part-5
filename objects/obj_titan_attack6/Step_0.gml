event_inherited();
if (!instance_exists(id) || !instance_exists(obj_battlebox)) exit;   // (it's ended this frame)
if (t >= beam_start && t < attack_duration - beam_stop - beam_warn - beam_fire && (t - beam_start) mod beam_gap == 0)
{
    var _k = titan_beam_soul_k();
    if (random(1) < beam_cross) { titan_beam_add("row", _k.y); titan_beam_add("col", _k.x); }
    else if (irandom(1) == 0) titan_beam_add("row", _k.y);
    else titan_beam_add("col", _k.x);
}
titan_beams_step();