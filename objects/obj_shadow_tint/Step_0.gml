// floor tiles (and any other room layers in range): per-pixel shadow through the shader
var _layers = layer_get_all();
for (var i = 0; i < array_length(_layers); i++)
{
    var _l = _layers[i];
    var _d = layer_get_depth(_l);
    if (_d <= front_depth || _d >= back_depth) continue;
    if (array_contains(skip_layers, layer_get_name(_l))) continue;
    if (tiles_only && layer_tilemap_get_id(_l) == -1) continue;
    layer_script_begin(_l, scr_shadow_tint_begin);
    layer_script_end(_l, scr_shadow_tint_end);
}

// characters: shaded by how close their feet are to the fountain
tint_col = make_color_rgb(tint_r * 255, tint_g * 255, tint_b * 255);
for (var i = 0; i < array_length(shade_objs); i++)
{
    with (shade_objs[i])
    {
        var _s = other.flat ? other.strength : other.shade_at(scr_get_feet(id).y);
        image_blend = merge_color(c_white, other.tint_col, _s);
    }
}