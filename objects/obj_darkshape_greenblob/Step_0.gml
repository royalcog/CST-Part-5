if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

t++;
if (collected)
{
    f += 0.25;   // the sparkle: frames 7-9
    if (f >= 10) instance_destroy();
    exit;
}

if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    image_alpha -= 0.08;
    if (image_alpha <= 0) instance_destroy();
    exit;
}

f = (f + 0.125) mod 6;   // Deltarune only loops frames 0-5
spd *= friction;

// homes in on the SOUL, harder the closer it is (Deltarune's)
if (t >= home_delay && instance_exists(obj_soul))
{
    var _d = max(1, point_distance(x, y, obj_soul.x, obj_soul.y));
    dir = point_direction(x, y, obj_soul.x, obj_soul.y);
    spd = scr_approach(spd, max_speed, acc / _d);
}
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);

// picked up
if (instance_exists(obj_soul) && point_distance(x, y, obj_soul.x, obj_soul.y) <= pickup_r)
{
    scr_tp_add(tp_gain);
    with (obj_tp_bar) courage_flash();
    audio_stop_sound(snd_swallow);
    audio_stop_sound(snd_eye_telegraph);
    audio_play_sound(snd_swallow, 1, false, size * 0.2);
    audio_play_sound(snd_eye_telegraph, 1, false, size * 0.2, 0, 2);
    collected = true;
    f = 7;
}