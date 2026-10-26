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

// spared: fades out white while the stars fly off
if (gone && spared)
{
    gone_t++;
    image_alpha = max(0, 1 - gone_t / 30);
    for (var i = 0; i < array_length(stars); i++)
    {
        var _s = stars[i];
        _s.x += lengthdir_x(_s.spd, _s.dir);
        _s.y += lengthdir_y(_s.spd, _s.dir);
        _s.spd *= 0.95;
        _s.rot += _s.vr;
        _s.f += 0.25;   // 15 frames a second
    }
    if (gone_t >= 45) instance_destroy();
}
// defeated: red, then sliced into strips that drift apart, with red mist coming off
else if (gone)
{
    gone_t++;
    if (gone_t == die_red_time) audio_play_sound(snd_damagetaken, 1, false, 0.6, 0, 0.6);
    if (gone_t > die_red_time && gone_t mod 2 == 0)
    {
        repeat (3) array_push(mist, { x: x + random_range(-30, 30), y: y + random_range(-40, 40), vx: random_range(-0.6, 0.6), vy: random_range(-1.5, -0.4), a: 1, sz: random_range(2, 5) });
    }
    for (var i = array_length(mist) - 1; i >= 0; i--)
    {
        var _m = mist[i];
        _m.x += _m.vx; _m.y += _m.vy; _m.a -= 0.03; _m.sz += 0.08;
        if (_m.a <= 0) array_delete(mist, i, 1);
    }
    if (gone_t >= die_red_time + die_slice_time && array_length(mist) == 0) instance_destroy();
}