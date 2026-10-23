t++;

// stays on the Spawn while it's still around
if (instance_exists(target)) { cx = target.x; cy = target.y; }

if (kind == "swarm")
{
    if (!burst_done && t >= swarm_len)
    {
        burst_done = true;
        for (var i = 0; i < burst_count; i++)
        {
            var _a = i * 360 / burst_count + spin0;
            array_push(bursts, { x: cx, y: cy, vx: lengthdir_x(burst_speed, _a), vy: lengthdir_y(burst_speed, _a) });
        }
        if (burst_sound != noone) audio_play_sound(burst_sound, 1, false, 0.6);
    }
    for (var i = 0; i < array_length(bursts); i++)
    {
        var _b = bursts[i];
        _b.x += _b.vx; _b.y += _b.vy;
        _b.vx *= 0.94; _b.vy *= 0.94;
    }
    if (t >= swarm_len + burst_len) instance_destroy();
}
else if (t >= buster_len) instance_destroy();