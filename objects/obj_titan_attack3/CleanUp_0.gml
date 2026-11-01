// (any chain sounds still looping)
if (wave != undefined)
{
    if (wave.snd_extend != noone) audio_stop_sound(wave.snd_extend);
    if (wave.snd_wave != noone) audio_stop_sound(wave.snd_wave);
}
if (grab != undefined && grab.snd != noone) audio_stop_sound(grab.snd);