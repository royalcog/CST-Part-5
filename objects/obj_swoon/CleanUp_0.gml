// hard stop on the swoon layers whenever this instance goes away (normal end, room change, etc.)
for (var i = 0; i < array_length(sounds); i++)
{
    audio_stop_sound(sounds[i]);
}