t++;

switch (stage)
{
    case "blackout":
        a_black = clamp(t / blackout_fade, 0, 1);
        if (t >= blackout_hold) crescent();
    break;

    case "crescent":
        a_black    = 1;
        a_crescent = clamp(t / crescent_fade, 0, 1);
        if (t >= crescent_hold)
        {
            stage = "hold";
            t = 0;
            if (on_crescent_done != undefined) on_crescent_done();
        }
    break;

    case "hold":
        a_black    = 1;
        a_crescent = 1;
    break;

    case "open":
        a_black    = 1 - clamp(t / open_fade, 0, 1);
        a_crescent = a_black;
        if (t == open_wings_at)
        {
            audio_play_sound(snd_titan_wingshut, 1, false);
            drawstate = "undefense";
            wing_t    = 6;
        }
    break;
}

// the closed wings: the star circles a little (only until it starts opening)
if (drawstate == "defense end")
{
    spd = min(wobble_max, spd + wobble_accel);
    if (stage != "open") rotation = (rotation + spd) mod 360;
    siner += anim_speed;
}

// opening: the wings play backwards to their first frame, then it idles
if (drawstate == "undefense")
{
    wing_t = max(0, wing_t - wing_speed);
    if (wing_t < afterimage_at && !after_on && !after_grab) after_grab = true;   // Draw GUI grabs the screen
    if (wing_t < 0.1)
    {
        drawstate = "idle";
        stage = "idle";
        t = 0;
    }
}

if (drawstate == "idle")
{
    siner += anim_speed;
    if (!open_done && stage == "idle" && t >= 30)
    {
        open_done = true;
        if (on_open_done != undefined) on_open_done();
    }
}

// the screen afterimage grows and fades
if (after_on)
{
    after_scale += afterimage_grow;
    after_alpha  = max(0, after_alpha - afterimage_fade);
    if (after_alpha <= 0)
    {
        after_on = false;
        if (surface_exists(after_surf)) { surface_free(after_surf); after_surf = -1; }
    }
}