event_inherited();
if (!instance_exists(id) || !instance_exists(obj_battlebox)) exit;   // (the attack's ended this frame)

// King's spade bombs, erupting from the sides of the screen
if (t >= bomb_start && t < attack_duration - bomb_stop && (t - bomb_start) mod bomb_gap == 0)
{
    var _side = choose(-1, 1);
    spawn_bomb(_side);
    if (random(1) < bomb_pair) spawn_bomb(-_side);
}