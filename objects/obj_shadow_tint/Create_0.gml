// the fountain's shadow: darkest right at the platform edge, fading out toward the door (bottom of the screen)
tint_r = 0.32;
tint_g = 0.36;
tint_b = 0.70;
strength = 1;     // 0-1, how dark it gets at its darkest

near_y = 364;     // room y where the shadow is darkest (the platform edge)
far_y  = 500;     // room y where it's faded out (a bit past the bottom, so the bottom isn't fully lit)

front_depth = -9000;   // layers at or in front of this are skipped (fades, textbox, UI)
back_depth  = 350;     // layers at or behind this are skipped (the fountain, the background)
skip_layers = ["Fountain", "Background", "UI", "Blackbox"];

// characters shaded by where their feet are (whole body, not per-pixel)
shade_objs = [obj_susie, obj_ralsei];

// flat = true: the same shadow everywhere (the tower climb: you're on the Titan's tower the whole way up),
// instead of fading out away from near_y. tiles_only = true: only tile layers get the per-pixel shadow
// (instance layers are left alone, so effects/enemies don't get dimmed)
flat       = false;
tiles_only = false;

tint_col = make_color_rgb(tint_r * 255, tint_g * 255, tint_b * 255);

/// how much shadow at room y _y (same falloff as the shader)
shade_at = function(_y)
{
    if (flat) return strength;
    var _k = clamp((_y - near_y) / (far_y - near_y), 0, 1);
    _k = _k * _k * (3 - 2 * _k);
    return strength * (1 - _k);
}