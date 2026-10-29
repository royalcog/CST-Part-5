// the soul's light: breathes and flickers like a flame, swells while it's burning something away,
// and pulses out a ring whenever a copy's purified
if (instance_exists(obj_soul))
{
    var _sx = round(glow_x), _sy = round(glow_y);
    var _r  = aura_radius * (1 + 0.04 * sin(t * 0.05) + 0.02 * sin(t * 0.17 + 1.3) + 0.08 * flare);
    var _b  = glow_strength * (1 + 0.6 * flare + 0.5 * burst);
    gpu_set_blendmode(bm_add);
    draw_set_colour(c_white);
    // soft layers, each flickering on its own
    for (var i = 0; i < 8; i++)
    {
        var _fl = 0.02 * sin(t * (0.13 + i * 0.031) + i * 1.7) + random_range(-0.008, 0.008);
        draw_set_alpha(_b * (0.065 + _fl));
        draw_circle(_sx, _sy, _r * (1 - i / 9), false);
    }
    // a bright core right around the SOUL
    draw_set_alpha(_b * 0.25);
    draw_circle(_sx, _sy, 10 + 2 * sin(t * 0.2), false);
    // the edge: a shimmering double ring
    draw_set_alpha(_b * (0.25 + 0.12 * sin(t * 0.08)));
    draw_circle(_sx, _sy, _r, true);
    draw_set_alpha(_b * 0.1);
    draw_circle(_sx, _sy, _r + 2 + sin(t * 0.11), true);
    // a copy was just purified: a ring of light pulses out
    if (burst > 0)
    {
        draw_set_alpha(burst * 0.5);
        draw_circle(_sx, _sy, _r + (1 - burst) * 30, true);
        draw_circle(_sx, _sy, _r + (1 - burst) * 30 + 1, true);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// specks
draw_set_colour(c_white);
for (var i = 0; i < array_length(particles); i++)
{
    var _p = particles[i];
    draw_rectangle(_p.x - _p.size, _p.y - _p.size, _p.x + _p.size, _p.y + _p.size, false);
}