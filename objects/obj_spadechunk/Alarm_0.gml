if (spawn_index < array_length(spawn_y))
{
    var test_spade = instance_create_layer(
        680,
        spawn_y[spawn_index],
        "Instances",
        obj_spades
    );

    audio_play_sound(snd_spear_appear, 1, false);

    spawn_index++;

    alarm[0] = game_get_speed(gamespeed_fps);
}
