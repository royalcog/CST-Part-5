// obj_friend_laugh_attack — Step event
if (!started)
{
    started = true;
    if (instance_exists(obj_friend))
    {
        obj_friend.sprite_index = spr_friend_laugh;
        obj_friend.image_index = 0;
        obj_friend.image_speed = 1;
    }
    audio_play_sound(snd_friendlaugh, 5, false);
}

timer--;
if (timer <= 0)
{
    instance_destroy();
}