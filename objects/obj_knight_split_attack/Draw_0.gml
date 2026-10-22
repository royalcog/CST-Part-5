var _in = scr_get_box_interior();

// bright line where the box got cut, fades right after
if (seam_flash > 0)
{
    draw_set_color(c_white);
    draw_set_alpha(seam_flash);
    if (split_axis == "h") draw_line_width(_in.x1 - slide_amp, seam_y, _in.x2 + slide_amp, seam_y, 3);
    else                   draw_line_width(seam_x, _in.y1 - slide_amp, seam_x, _in.y2 + slide_amp, 3);
    draw_set_alpha(1);
}

// the soul, cut along the seam (obj_soul skips its own draw while the box is split)
if (split_active && instance_exists(obj_soul))
{
    var _parts = soul_parts();
    for (var i = 0; i < array_length(_parts); i++)
    {
        var _p = _parts[i];
        draw_sprite_part_ext(obj_soul.sprite_index, obj_soul.image_index, _p.px, _p.py, _p.pw, _p.ph,
            round(_p.x), round(_p.y), obj_soul.image_xscale, obj_soul.image_yscale, obj_soul.image_blend, obj_soul.image_alpha);
    }
}

// waves of light
for (var i = 0; i < array_length(waves); i++)
{
    var _w = waves[i];
    var _a = clamp(_w.travelled / (_w.spd * 4), 0, 1) * clamp((_w.travel_max - _w.travelled) / 60, 0, 1);

    gpu_set_blendmode(bm_add);
    var _n = array_length(_w.trail);
    for (var j = _n - 1; j >= 0; j--)
    {
        draw_wave(_w.trail[j].x, _w.trail[j].y, _w.dir, wave_thickness, wave_color, _a * 0.35 * (1 - (j + 1) / (_n + 1)));
    }
    draw_wave(_w.x, _w.y, _w.dir, wave_thickness * 2.6, wave_color, _a * 0.3); // glow
    gpu_set_blendmode(bm_normal);
    draw_wave(_w.x, _w.y, _w.dir, wave_thickness, wave_color, _a);
}

// the cutting sword
if (cut_sword != undefined)
{
    var _s = cut_sword;
    if (_s.state == "charge")
    {
        draw_sword_charge(_s.x, _s.y, _s.angle, _s.alpha, clamp(_s.t / cut_charge, 0, 1));
    }
    else
    {
        var _n = array_length(_s.trail);
        for (var j = _n - 1; j >= 0; j--)
        {
            draw_sword_ghost(_s.trail[j].x, _s.trail[j].y, _s.angle, flight_alpha * (1 - (j + 1) / (_n + 1)));
        }
        draw_sword_ghost(_s.x, _s.y, _s.angle, flight_alpha);
    }
}

// slash swords
for (var i = 0; i < array_length(swords); i++)
{
    var _s = swords[i];
    if (_s.state == "charge")
    {
        draw_sword_charge(_s.x, _s.y, _s.draw_angle, _s.alpha, clamp(_s.t / _s.charge, 0, 1));
    }
    else
    {
        var _n = array_length(_s.trail);
        for (var j = _n - 1; j >= 0; j--)
        {
            draw_sword_ghost(_s.x, _s.y, _s.trail[j], _s.alpha * 0.4 * (1 - (j + 1) / (_n + 1)));
        }
        draw_sword_ghost(_s.x, _s.y, _s.draw_angle, _s.alpha);
    }
}