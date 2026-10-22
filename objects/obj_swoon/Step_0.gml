timer++;

// fade the knight-cut layers out over the final frames so they end exactly with the overlay
var _fade_start = duration - fade_frames;
if (timer > _fade_start)
{
    var _g = sound_gain * clamp((duration - timer) / fade_frames, 0, 1);
    for (var i = 0; i < array_length(sounds); i++)
    {
        audio_sound_gain(sounds[i], _g, 0);
    }
}

if (timer >= duration)
{
    var _cb = on_finish;
    instance_destroy();   // Clean Up stops the sounds
    if (_cb != undefined) _cb();
}