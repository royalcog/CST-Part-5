/// scr_sparkle_heroes(_heroes)
/// Plays snd_sparklegem once and spawns a brief sparkle burst on every
/// hero instance passed in (their magic being returned to them).
function scr_sparkle_heroes(_heroes)
{
    audio_play_sound(snd_sparklegem, 1, false);

    for (var _i = 0; _i < array_length(_heroes); _i++)
    {
        var _h = _heroes[_i];
        if (instance_exists(_h))
        {
            instance_create_depth(0, 0, _h.depth - 1, obj_hero_sparkle_fx).target = _h;
        }
    }
}