// the Titan's lasers across the battle box, for the 6-person battle's remixed attacks (obj_titan_attack6/7/8).
// the attack calls titan_beams_init() in its Create, titan_beams_step() in its Step and titan_beams_draw() in its Draw
// (they all run as that attack). a beam's a "row" or a "col" (straight across the box, _pos 0-1 of the way across it)
// or a "spin" (a line through the box's middle, turning _spin degrees a frame). each flashes a thin warning line where
// it'll be first, then fires, then fades. it all follows the box if it turns

function titan_beams_init()
{
    beams       = [];
    beam_warn   = 45;    // frames the warning line flashes...
    beam_fire   = 20;    // ...then it fires this long (a "spin" gives its own)...
    beam_fade   = 10;    // ...and fades
    beam_w      = 16;    // px wide
    beam_damage = 110;
    beam_soul_r = 4;     // px: the SOUL's hitbox (a circle in its middle)
    beam_out    = 40;    // px past the box's walls it reaches
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

/// a beam's two ends, in the room
function titan_beam_ends(_b)
{
    var _in = scr_get_box_interior();
    var _a, _c;
    if (_b.kind == "row")
    {
        var _y = lerp(_in.y1, _in.y2, _b.pos);
        _a = scr_box_local_to_world(_in.x1 - beam_out, _y);
        _c = scr_box_local_to_world(_in.x2 + beam_out, _y);
    }
    else if (_b.kind == "col")
    {
        var _x = lerp(_in.x1, _in.x2, _b.pos);
        _a = scr_box_local_to_world(_x, _in.y1 - beam_out);
        _c = scr_box_local_to_world(_x, _in.y2 + beam_out);
    }
    else
    {
        var _cx = (_in.x1 + _in.x2) / 2, _cy = (_in.y1 + _in.y2) / 2;
        var _r  = point_distance(_in.x1, _in.y1, _in.x2, _in.y2) / 2 + beam_out;
        _a = scr_box_local_to_world(_cx + lengthdir_x(_r, _b.ang), _cy + lengthdir_y(_r, _b.ang));
        _c = scr_box_local_to_world(_cx - lengthdir_x(_r, _b.ang), _cy - lengthdir_y(_r, _b.ang));
    }
    return { x1: _a.x, y1: _a.y, x2: _c.x, y2: _c.y };
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
            // the SOUL's distance from the beam's line
            var _e  = titan_beam_ends(_b);
            var _dx = _e.x2 - _e.x1, _dy = _e.y2 - _e.y1;
            var _k  = clamp(((obj_soul.x - _e.x1) * _dx + (obj_soul.y - _e.y1) * _dy) / max(1, _dx * _dx + _dy * _dy), 0, 1);
            if (point_distance(obj_soul.x, obj_soul.y, _e.x1 + _dx * _k, _e.y1 + _dy * _k) < beam_w / 2 + beam_soul_r)
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
    if (!instance_exists(obj_battlebox)) return;
    var _glow = make_colour_rgb(90, 40, 200), _mid = make_colour_rgb(170, 110, 255), _hot = make_colour_rgb(230, 215, 255);
    for (var i = 0; i < array_length(beams); i++)
    {
        var _b = beams[i];
        var _e = titan_beam_ends(_b);
        if (_b.t < beam_warn)
        {
            // the warning: a thin flashing line where it'll be
            draw_set_alpha(((_b.t div 4) mod 2 == 0) ? 0.9 : 0.35);
            draw_line_width_colour(_e.x1, _e.y1, _e.x2, _e.y2, 2, _mid, _mid);
            draw_set_alpha(1);
            continue;
        }
        var _k = (_b.t < beam_warn + _b.fire) ? 1 : 1 - (_b.t - beam_warn - _b.fire) / beam_fade;
        var _w = beam_w * (0.6 + 0.4 * _k) * (1 + 0.08 * sin(_b.t * 1.7));
        gpu_set_blendmode(bm_add);
        titan_beam_strip(_e.x1, _e.y1, _e.x2, _e.y2, _w * 3,   _glow,   0.6 * _k);
        titan_beam_strip(_e.x1, _e.y1, _e.x2, _e.y2, _w * 1.6, _mid,    0.9 * _k);
        titan_beam_strip(_e.x1, _e.y1, _e.x2, _e.y2, _w * 0.8, _hot,    _k);
        titan_beam_strip(_e.x1, _e.y1, _e.x2, _e.y2, _w * 0.4, c_white, _k);
        gpu_set_blendmode(bm_normal);
    }
}