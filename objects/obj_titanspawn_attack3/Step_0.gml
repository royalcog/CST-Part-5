event_inherited();
if (array_contains(fish_times, t)) spawn_fish();

if (t >= dash_start && (t - dash_start) mod dash_gap == 0 && t < attack_duration - 60)
{
    spawn_dash();
    if (random(1) < dash_pair) spawn_dash();
}