var _layers = layer_get_all();
for (var i = 0; i < array_length(_layers); i++)
{
    if (layer_get_script_begin(_layers[i]) == scr_shadow_tint_begin)
    {
        layer_script_begin(_layers[i], -1);
        layer_script_end(_layers[i], -1);
    }
}

for (var i = 0; i < array_length(shade_objs); i++)
{
    with (shade_objs[i]) image_blend = c_white;
}