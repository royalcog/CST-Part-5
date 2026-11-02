var _vx = camera_get_view_x(view_camera[0]), _vy = camera_get_view_y(view_camera[0]);

// ---------------------------------------------------------------- the SOUL's light
if (instance_exists(obj_soul) && aura_radius > 0)
{
    var _sx = round(obj_soul.x), _sy = round(obj_soul.y);
    var _r  = aura_radius * (1 + 0.04 * sin(t * 0.05) + 0.02 * sin(t * 0.17 + 1.3));
    gpu_set_blendmode(bm_add);
    draw_set_colour(c_white);
    for (var i = 0; i < 8; i++)
    {
        draw_set_alpha(0.065 + 0.02 * sin(t * (0.13 + i * 0.031) + i * 1.7));
        draw_circle(_sx, _sy, _r * (1 - i / 9), false);
    }
    draw_set_alpha(0.25);
    draw_circle(_sx, _sy, 10 + 2 * sin(t * 0.2), false);
    draw_set_alpha(0.25 + 0.12 * sin(t * 0.08));
    draw_circle(_sx, _sy, _r, true);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// ---------------------------------------------------------------- afterimages (behind the hands)
for (var i = 0; i < array_length(afters); i++)
{
    var _a = afters[i];
    draw_sprite_ext(spr_titan_battle_hand, 0, _a.x, _a.y, _a.xs, _a.ys, _a.ang, c_white, _a.a * image_alpha);
}

// ---------------------------------------------------------------- the hands + fingers, onto the surface
if (!surface_exists(hands_surface)) hands_surface = surface_create(vw, vh);
surface_set_target(hands_surface);
draw_clear_alpha(c_white, 0);

for (var h = 0; h < 2; h++)
{
    var _h = hands[h];
    if (_h.gone) continue;
    draw_sprite_ext(spr_titan_battle_hand, 0, _h.x - _vx, _h.y - _vy, _h.xs, _h.ys, _h.ang, c_white, 1);
    if (_h.ov_t >= 0)
    {
        gpu_set_fog(true, c_white, 0, 0);
        draw_sprite_ext(spr_titan_battle_hand, 0, _h.x - _vx, _h.y - _vy, _h.xs, _h.ys, _h.ang, c_white, min(1, _h.ov_t / 60));
        gpu_set_fog(false, c_white, 0, 0);
    }
    for (var i = 0; i < 4; i++)
    {
        var _f = _h.fingers[i];
        if (_f.alive) draw_sprite_ext(finger_sprite, floor(_f.img), _f.x - _vx, _f.y - _vy, _f.xs, _f.ys, _f.ang, c_white, 1);
    }
}

// the fingers' dark layer + weak spots, lit up white by the SOUL's light
for (var h = 0; h < 2; h++)
{
    var _h = hands[h];
    if (_h.gone) continue;
    for (var i = 0; i < 4; i++)
    {
        var _f = _h.fingers[i];
        if (!_f.alive) continue;
        var _w  = weak_pos(_f);
        var _sx = 0, _sy = 0;
        if (instance_exists(obj_soul) && point_distance(_w.x, _w.y, obj_soul.x, obj_soul.y) < 64) { _sx = choose(-1, 0, 1); _sy = choose(-1, 0, 1); }
        var _fi = floor(_f.img);
        // the eye shuts as the finger curls in (frames 0-4), and opens again as it uncurls
        var _m4 = (_fi <= 4) ? _fi : 8 - _fi;
        var _wi = max(0, 3 - _m4);
        draw_sprite_ext(spr_titan_battle_finger_dark, _fi, _f.x - _vx, _f.y - _vy, _f.xs, _f.ys, _f.ang, c_white, 1);
        draw_sprite_ext(weak_sprite, _wi, _w.x + _sx - _vx, _w.y + _sy - _vy, _f.xs, _f.ys, _f.ang - 15 * _f.ys, c_white, 1);
        if (_f.light > 0)
        {
            gpu_set_blendmode(bm_add);
            gpu_set_fog(true, c_white, 0, 0);
            draw_sprite_ext(spr_titan_battle_finger_dark, _fi, _f.x - _vx, _f.y - _vy, _f.xs, _f.ys, _f.ang, c_white, _f.light);
            draw_sprite_ext(weak_sprite, _wi, _w.x + _sx - _vx, _w.y + _sy - _vy, _f.xs, _f.ys, _f.ang - 15 * _f.ys, c_white, _f.light);
            gpu_set_fog(false, c_white, 0, 0);
            gpu_set_blendmode(bm_normal);
        }
    }
}
surface_reset_target();

// in 15px strips, wobbling sideways while they fade in or out
draw_set_alpha(image_alpha);
var _amp = 3 - image_alpha * 3;
for (var a = 0; a < ceil(vh / 15); a++)
    draw_surface_part(hands_surface, 0, a * 15, vw, 15, _vx + sin(a + t / 2) * _amp, _vy + a * 15);
draw_set_alpha(1);

// ---------------------------------------------------------------- bullets, explosions, specks
for (var i = 0; i < array_length(bullets); i++)
{
    var _b = bullets[i];
    draw_sprite_ext(spr_wibblywobbly_dark_bullet, floor(_b.f), _b.x, _b.y, _b.s, _b.s, 0, c_white, _b.a);
}
for (var i = 0; i < array_length(booms); i++)
{
    var _m = booms[i];
    var _s = lerp(_m.s_from, _m.s_to, min(1, _m.t / _m.s_time));
    draw_sprite_ext(_m.spr, floor(_m.f), _m.x, _m.y, _s * _m.xs, _s * _m.ys, _m.ang, c_white, 1);
}
draw_set_colour(c_white);
for (var i = 0; i < array_length(specks); i++)
{
    var _p = specks[i];
    draw_rectangle(_p.x - _p.size, _p.y - _p.size, _p.x + _p.size, _p.y + _p.size, false);
}