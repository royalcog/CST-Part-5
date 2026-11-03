event_inherited();
if (!instance_exists(id) || !instance_exists(obj_battlebox)) exit;   // (it's ended this frame)
if (array_contains(spin_at, t)) titan_beam_add("spin", random(180), choose(-1, 1) * spin_speed, spin_fire);
titan_beams_step();