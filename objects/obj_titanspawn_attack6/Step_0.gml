event_inherited();
if (t >= mine_start && (t - mine_start) mod mine_gap == 0 && t < attack_duration - 120) spawn_mine();