if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (collected) { ring++; if (ring >= 10) instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    image_alpha -= 0.08;
    if (image_alpha <= 0) instance_destroy();
    exit;
}

f = (f + 0.25) mod 6;   // Deltarune loops frames 0-5
if (state == "orb") exit;   // the fish moves it

t++;
if (state == "priming")
{
    var _k = min(1, t / prime_time);
    scale = lerp(scale_from, size_to, _k);
    col   = merge_colour(col_from, c_yellow, _k);
    if (_k >= 1) state = "active";
}

spd *= friction;
if (state == "active" && instance_exists(obj_soul))
{
    var _d = max(1, point_distance(x, y, obj_soul.x, obj_soul.y));
    dir = point_direction(x, y, obj_soul.x, obj_soul.y);
    spd = scr_approach(spd, max_speed, acc / _d);
}
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);

// picked up (only once it's done priming)
if (state == "active" && instance_exists(obj_soul) && point_distance(x, y, obj_soul.x, obj_soul.y) <= pickup_r)
{
    if (global.tp.broken) scr_courage_heal(1);   // the TP bar's broken: it heals someone instead
    else
    {
        scr_tp_add(tp_gain);
        with (obj_tp_bar) courage_flash();
    }
    audio_stop_sound(snd_swallow);
    audio_stop_sound(snd_eye_telegraph);
    audio_play_sound(snd_swallow, 1, false, size * 0.2);
    audio_play_sound(snd_eye_telegraph, 1, false, size * 0.2, 0, 2);
    collected = true;
}