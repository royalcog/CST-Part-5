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

f = (f + 0.125) mod 7;   // wobbling blob: frames 0-6
x = lerp(x, hx, 0.03);
y = lerp(y, hy, 0.03);

if (instance_exists(obj_soul) && point_distance(x, y, obj_soul.x, obj_soul.y) <= pickup_r)
{
    scr_tp_add(tp_gain);
    audio_play_sound(pickup_snd, 1, false);
    collected = true;
    f = 7;
}