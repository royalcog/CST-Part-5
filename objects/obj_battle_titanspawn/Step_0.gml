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


// hurt: the hurt sprite and a shake, then back
if (hurt_t > 0)
{
    hurt_t--;
    sprite_index = (hurt_t > 0) ? spr_titanspawn_hurt : spr_titanspawn_idle;
}
// defeated / spared: fade out, then it's gone
if (gone)
{
    gone_t++;
    image_alpha = max(0, 1 - gone_t / 30);
    if (gone_t >= 30 && hurt_t <= 0) instance_destroy();
}