// the Titan's lasers inside the battle box, for the 6-person battle's remixed attacks (obj_titan_attack6/7/8).
// the attack calls titan_beams_init() in its Create, titan_beams_step() in its Step, titan_beams_draw() in its Draw and
// titan_beams_free() in its Clean Up (they all run as that attack). a beam's a "row" or a "col" (straight across the
// box, _pos 0-1 of the way across it) or a "spin" (a line through the box's middle, turning _spin degrees a frame).
// each flashes a thin warning line where it'll be first, then fires, then fades. everything's drawn onto a surface the
// size of the box's inside, in the box's own frame, then put back turned with the box: nothing shows outside it

function titan_beams_init()
{
    beams       = [];
    beam_surf   = -1;
    beam_warn   = 45;    // frames the warning line flashes...
    beam_fire   = 20;    // ...then it fires this long (a "spin" gives its own)...
    beam_fade   = 10;    // ...and fades
    beam_w      = 16;    // px wide
    beam_damage = 110;
    beam_soul_r = 4;     // px: the SOUL's hitbox (a circle in its middle)
}

function titan_beam_add(_kind, _pos, _spin = 0, _fire = -1)
{
    array_push(beams, { kind: _kind, pos: _pos, spin: _spin, ang: (_kind == "spin") ? _pos : 0, t: 0, fire: (_fire < 0) ? beam_fire : _fire });
    audio_play_sound(snd_eye_telegraph, 1, false, 0.6);
}

/// where the SOUL is across the box, 0-1 each way (for aiming at it)
function titan_beam_soul_k()
{
    if (!instance_exists(obj_soul) || !instance_exists(obj_battlebox)) return { x: 0.5, y: 0.5 };
    var _in = scr_get_box_interior();
    var _l  = scr_world_to_box_local(obj_soul.x, obj_soul.y);
    return { x: clamp((_l.x - _in.x1) / (_in.x2 - _in.x1), 0.08, 0.92), y: clamp((_l.y - _in.y1) / (_in.y2 - _in.y1), 0.08, 0.92) };
}

/// a beam's two ends in the box's own (unturned) frame: always on the box's walls
function titan_beam_ends(_b)
{
    var _in = scr_get_box_interior();
    if (_b.kind == "row")
    {
        var _y = lerp(_in.y1, _in.y2, _b.pos);
        return { x1: _in.x1, y1: _y, x2: _in.x2, y2: _y };
    }
    if (_b.kind == "col")
    {
        var _x = lerp(_in.x1, _in.x2, _b.pos);
        return { x1: _x, y1: _in.y1, x2: _x, y2: _in.y2 };
    }
    // through the middle, cut off where it meets the walls
    var _cx = (_in.x1 + _in.x2) / 2, _cy = (_in.y1 + _in.y2) / 2;
    var _dx = lengthdir_x(1, _b.ang), _dy = lengthdir_y(1, _b.ang);
    var _r  = min((abs(_dx) > 0.001) ? (_in.x2 - _in.x1) / 2 / abs(_dx) : 99999, (abs(_dy) > 0.001) ? (_in.y2 - _in.y1) / 2 / abs(_dy) : 99999);
    return { x1: _cx + _dx * _r, y1: _cy + _dy * _r, x2: _cx - _dx * _r, y2: _cy - _dy * _r };
}

function titan_beams_step()
{
    if (!instance_exists(obj_battlebox)) { beams = []; return; }
    for (var i = array_length(beams) - 1; i >= 0; i--)
    {
        var _b = beams[i];
        _b.t++;
        _b.ang += _b.spin;
        if (_b.t == beam_warn) { audio_play_sound(snd_chargeshot_fire, 1, false, 0.5); scr_camera_shake(2, 8); }
        if (_b.t >= beam_warn && _b.t < beam_warn + _b.fire && instance_exists(obj_soul))
        {
            // the SOUL's distance from the beam's line (in the box's own frame)
            var _e  = titan_beam_ends(_b);
            var _s  = scr_world_to_box_local(obj_soul.x, obj_soul.y);
            var _dx = _e.x2 - _e.x1, _dy = _e.y2 - _e.y1;
            var _k  = clamp(((_s.x - _e.x1) * _dx + (_s.y - _e.y1) * _dy) / max(1, _dx * _dx + _dy * _dy), 0, 1);
            if (point_distance(_s.x, _s.y, _e.x1 + _dx * _k, _e.y1 + _dy * _k) < beam_w / 2 + beam_soul_r)
                scr_soul_take_hit(beam_damage, c_white, c_white);
        }
        if (_b.t >= beam_warn + _b.fire + beam_fade) array_delete(beams, i, 1);
    }
}

/// a soft band: _col down the middle, fading out to its edges (under bm_add)
function titan_beam_strip(_x1, _y1, _x2, _y2, _w, _col, _a)
{
    var _d  = point_direction(_x1, _y1, _x2, _y2);
    var _nx = lengthdir_x(_w / 2, _d + 90), _ny = lengthdir_y(_w / 2, _d + 90);
    for (var _side = -1; _side <= 1; _side += 2)
    {
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_x1, _y1, _col, _a);
        draw_vertex_colour(_x1 + _nx * _side, _y1 + _ny * _side, c_black, _a);
        draw_vertex_colour(_x2, _y2, _col, _a);
        draw_vertex_colour(_x2 + _nx * _side, _y2 + _ny * _side, c_black, _a);
        draw_primitive_end();
    }
}

function titan_beams_draw()
{
    if (!instance_exists(obj_battlebox) || array_length(beams) == 0) return;
    var _in  = scr_get_box_interior();
    var _ang = obj_battlebox.box_angle;
    var _ox  = floor(_in.x1), _oy = floor(_in.y1);
    var _w   = max(1, ceil(_in.x2) - _ox), _h = max(1, ceil(_in.y2) - _oy);
    if (!surface_exists(beam_surf) || surface_get_width(beam_surf) != _w || surface_get_height(beam_surf) != _h)
    {
        if (surface_exists(beam_surf)) surface_free(beam_surf);
        beam_surf = surface_create(_w, _h);
    }

    // onto the box-sized surface, in the box's own frame
    var _glow = make_colour_rgb(90, 40, 200), _mid = make_colour_rgb(170, 110, 255), _hot = make_colour_rgb(230, 215, 255);
    surface_set_target(beam_surf);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendmode(bm_add);
    for (var i = 0; i < array_length(beams); i++)
    {
        var _b = beams[i];
        var _e = titan_beam_ends(_b);
        var _x1 = _e.x1 - _ox, _y1 = _e.y1 - _oy, _x2 = _e.x2 - _ox, _y2 = _e.y2 - _oy;
        if (_b.t < beam_warn)
        {
            // the warning: a thin flashing line where it'll be
            draw_set_alpha(((_b.t div 4) mod 2 == 0) ? 0.9 : 0.35);
            draw_line_width_colour(_x1, _y1, _x2, _y2, 2, _mid, _mid);
            draw_set_alpha(1);
            continue;
        }
        var _k  = (_b.t < beam_warn + _b.fire) ? 1 : 1 - (_b.t - beam_warn - _b.fire) / beam_fade;
        var _bw = beam_w * (0.6 + 0.4 * _k) * (1 + 0.08 * sin(_b.t * 1.7));
        titan_beam_strip(_x1, _y1, _x2, _y2, _bw * 3,   _glow,   0.6 * _k);
        titan_beam_strip(_x1, _y1, _x2, _y2, _bw * 1.6, _mid,    0.9 * _k);
        titan_beam_strip(_x1, _y1, _x2, _y2, _bw * 0.8, _hot,    _k);
        titan_beam_strip(_x1, _y1, _x2, _y2, _bw * 0.4, c_white, _k);
    }
    gpu_set_blendmode(bm_normal);
    surface_reset_target();

    // back into the room, turned with the box around its middle (the same way obj_box_bullet_drawer does it)
    var _c   = scr_box_center();
    var _off = scr_rotate_point(_ox - _c.x, _oy - _c.y, _ang);
    gpu_set_blendmode(bm_add);
    draw_surface_ext(beam_surf, _c.x + _off.x, _c.y + _off.y, 1, 1, _ang, c_white, 1);
    gpu_set_blendmode(bm_normal);
}

function titan_beams_free()
{
    if (surface_exists(beam_surf)) surface_free(beam_surf);
    beam_surf = -1;
}