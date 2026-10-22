function scr_fade_out_character(_target, _duration)
{
    if (instance_exists(_target))
    {
        with (_target)
        {
            image_alpha = lerp(image_alpha, 0, 1 / _duration);
        }
    }
}