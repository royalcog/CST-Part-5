t++;
flash = max(0, flash - 0.15);
bob += bob_speed;
side_k = lerp(side_k, side, side_lerp);
if (abs(side_k - side) < 0.01) side_k = side;
if (state != "shatter") follow_queen();

switch (state)
{
    case "build":
        if (t >= sections * section_every + 4)
        {
            state = "up";
            t = 0;
            if (build_sound != noone) audio_play_sound(build_sound, 1, false, 0.8);
        }
    break;

    case "down":   // pieces drop away top first, then it's gone
        if (t >= sections * 2 + 6) instance_destroy();
    break;

    case "crack":
        if (t >= crack_frames)
        {
            // every frame of spr_queen_shield_break is one shard, drawn where it sits in the shield
            for (var i = 0; i < sprite_get_number(spr_queen_shield_break); i++)
            {
                array_push(shards, { f: i, x: 0, y: 0, vx: random_range(1, 4.5) * (flip ? -1 : 1), vy: random_range(-5, -1.5), a: 1 });
            }
            if (break_sound != noone) audio_play_sound(break_sound, 1, false);
            state = "shatter";
            t = 0;
        }
    break;

    case "shatter":
        for (var i = 0; i < array_length(shards); i++)
        {
            var _s = shards[i];
            _s.vy += shard_gravity;
            _s.x += _s.vx;
            _s.y += _s.vy;
            _s.a = max(0, 1 - t / 40);
        }
        if (t >= 40) instance_destroy();
    break;
}