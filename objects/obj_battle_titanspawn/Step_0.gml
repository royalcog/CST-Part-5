t++;
switch (state)
{
    case "wait":
        if (t >= drop_delay) { state = "drop"; t = 0; from_y = y; }
    break;

    case "drop":
    {
        var _k = clamp(t / drop_time, 0, 1);
        x = home_x;
        y = lerp(from_y, home_y, 1 - power(1 - _k, 3));   // eases to a stop
        if (_k >= 1)
        {
            state  = "idle";
            landed = true;
            if (land_sound != noone) audio_play_sound(land_sound, 1, false, 0.8, 0, random_range(0.9, 1.1));
        }
    }
    break;

    case "idle":
        bob += bob_speed;
        y = home_y + sin(bob) * bob_amp;
    break;
}
depth = -2000 - y;