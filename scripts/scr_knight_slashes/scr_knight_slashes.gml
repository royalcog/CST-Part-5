/// shared pieces for the Knight's attacks: slash lines (warn -> cut) and his swing sprite.
/// every function here runs on the calling attack instance, so call the inits in its Create

// ---------------------------------------------------------------- the Knight's swing

function scr_knight_swing_init()
{
    knight_attack_sprite = spr_knight_attack;
    knight_hit_frame     = 3;   // frame of the swing where the cut lands (3 = the 4th frame, the big slash arc)
    knight_return_delay  = 60;  // after the swing finishes, how long until he goes back to normal (if nothing else swings)

    // where his feet are, in each sprite's own pixels (the swing's frame 0 matches his normal stance)
    knight_attack_feet_x = 65;
    knight_attack_feet_y = 95;
    knight_feet = [
        { spr: spr_roark_sword_appear_new, x: 48, y: 102 }
    ];
    knight_nudge_x       = 0;   // fine-tune on top of that
    knight_nudge_y       = 0;

    // how many steps it takes the swing to reach knight_hit_frame, so it can start that early
    var _spd = sprite_get_speed(knight_attack_sprite);
    var _per_step = (sprite_get_speed_type(knight_attack_sprite) == spritespeed_framespersecond)
                    ? _spd / game_get_speed(gamespeed_fps) : _spd;
    knight_swing_lead = (_per_step > 0) ? round(knight_hit_frame / _per_step) : 0;

    knight_saved         = undefined;
    knight_return_t      = 0;
}

/// where the Knight's feet are in sprite _spr's pixels (relative to its origin). falls back to bottom-center
function scr_knight_feet(_spr)
{
    if (_spr == knight_attack_sprite)
        return { x: knight_attack_feet_x - sprite_get_xoffset(_spr), y: knight_attack_feet_y - sprite_get_yoffset(_spr) };
    for (var i = 0; i < array_length(knight_feet); i++)
    {
        if (knight_feet[i].spr == _spr)
            return { x: knight_feet[i].x - sprite_get_xoffset(_spr), y: knight_feet[i].y - sprite_get_yoffset(_spr) };
    }
    return { x: sprite_get_width(_spr) / 2 - sprite_get_xoffset(_spr), y: sprite_get_height(_spr) - sprite_get_yoffset(_spr) };
}

/// the Knight plays his attack sprite. mid-swing it just keeps going (so close cuts read as one swing)
function scr_knight_swing()
{
    if (!instance_exists(obj_knight) || !sprite_exists(knight_attack_sprite)) return;
    var _k = obj_knight;

    if (is_undefined(knight_saved))
    {
        knight_saved = { spr: _k.sprite_index, img: _k.image_index, spd: _k.image_speed, loop: _k.anim_loop, x: _k.x, y: _k.y,
                         start_y: variable_instance_exists(_k, "start_y") ? _k.start_y : undefined };

        // the two sprites have different sizes/origins: line the swing up bottom-center to bottom-center
        // keep his feet where they were
        var _old = scr_knight_feet(_k.sprite_index);
        var _new = scr_knight_feet(knight_attack_sprite);
        _k.x = knight_saved.x + (_old.x - _new.x) * _k.image_xscale + knight_nudge_x;
        var _dy = (_old.y - _new.y) * _k.image_yscale + knight_nudge_y;
        _k.y = knight_saved.y + _dy;
        if (!is_undefined(knight_saved.start_y)) _k.start_y = knight_saved.start_y + _dy; // he bobs around start_y, so it has to move too
    }

    with (_k)
    {
        if (sprite_index != other.knight_attack_sprite || image_speed == 0 || image_index > other.knight_hit_frame)
        {
            sprite_index = other.knight_attack_sprite;
            image_index  = 0;
            image_speed  = 1;
            anim_loop    = false; // obj_knight freezes it on the last frame
        }
    }
    knight_return_t = knight_return_delay;
}

/// call every Step: puts him back a bit after his last swing finishes
function scr_knight_swing_step()
{
    if (is_undefined(knight_saved)) return;
    var _done = !instance_exists(obj_knight) || obj_knight.sprite_index != knight_attack_sprite || obj_knight.image_speed == 0;
    if (_done)
    {
        knight_return_t--;
        if (knight_return_t <= 0) scr_knight_swing_restore();
    }
}

/// back to exactly how he looked before the first swing (call in Clean Up too)
function scr_knight_swing_restore()
{
    if (is_undefined(knight_saved)) return;
    var _sv = knight_saved;
    knight_saved = undefined;
    if (!instance_exists(obj_knight)) return;
    with (obj_knight)
    {
        if (sprite_index != other.knight_attack_sprite) break; // something else already changed him
        sprite_index = _sv.spr;
        image_index  = _sv.img;
        image_speed  = _sv.spd;
        anim_loop    = _sv.loop;
        x = _sv.x;
        y = _sv.y;
        if (!is_undefined(_sv.start_y)) start_y = _sv.start_y;
    }
}

// ---------------------------------------------------------------- slashes

function scr_slashes_init()
{
    scr_knight_swing_init();
    slashes          = [];
    slash_damage     = 45;
    hit_color_top    = c_white;
    hit_color_bottom = c_white;
    cut_sound        = snd_knight_cut;
    cut_frames       = 10;   // how long the cut stays on screen
    hit_frames       = 4;    // only the first few frames of the cut can hit
    cut_width        = 14;   // starting thickness of the cut
    hit_half_width   = 6;    // how close to the line counts as a hit
    warn_color       = c_red;
    warn_blink       = 14;   // last frames of the warning blink
    cell_alpha_max   = 0.4;  // how red a marked sector gets right before the cut
    last_cut_snd     = 0;
    on_slash_cut     = undefined; // optional function(_slash): runs the frame a cut lands
}

/// the part of an endless line (through _px,_py at angle _ang) that's inside rect _r. undefined if it misses
function scr_slash_clip_line(_px, _py, _ang, _r)
{
    var _dx = lengthdir_x(1, _ang), _dy = lengthdir_y(1, _ang);
    var _t0 = -10000, _t1 = 10000;
    var _p = [-_dx, _dx, -_dy, _dy];
    var _q = [_px - _r.x1, _r.x2 - _px, _py - _r.y1, _r.y2 - _py];
    for (var i = 0; i < 4; i++)
    {
        if (abs(_p[i]) < 0.0001) { if (_q[i] < 0) return undefined; continue; }
        var _t = _q[i] / _p[i];
        if (_p[i] < 0) _t0 = max(_t0, _t); else _t1 = min(_t1, _t);
    }
    if (_t0 > _t1) return undefined;
    return { x1: _px + _dx * _t0, y1: _py + _dy * _t0, x2: _px + _dx * _t1, y2: _py + _dy * _t1 };
}

/// _cells = the 3x3 sectors it crosses, as [col, row] pairs (only used for the red sector warning)
function scr_slash_add(_seg, _charge, _cells = [])
{
    if (is_undefined(_seg)) return undefined;
    var _sl = { x1: _seg.x1, y1: _seg.y1, x2: _seg.x2, y2: _seg.y2,
                charge: _charge, t: 0, state: "warn", cells: _cells, swung: false };
    array_push(slashes, _sl);
    return _sl;
}

/// every cut a 3x3 grid over rect _b allows (3 rows, 3 columns, 2 diagonals) and the sectors each crosses
function scr_slash_grid_lines(_b)
{
    var _cw = (_b.x2 - _b.x1) / 3, _ch = (_b.y2 - _b.y1) / 3;
    var _all = [];
    for (var i = 0; i < 3; i++)
    {
        var _yy = _b.y1 + (i + 0.5) * _ch, _xx = _b.x1 + (i + 0.5) * _cw;
        array_push(_all, { seg: { x1: _b.x1, y1: _yy, x2: _b.x2, y2: _yy }, cells: [[0, i], [1, i], [2, i]] });
        array_push(_all, { seg: { x1: _xx, y1: _b.y1, x2: _xx, y2: _b.y2 }, cells: [[i, 0], [i, 1], [i, 2]] });
    }
    array_push(_all, { seg: { x1: _b.x1, y1: _b.y1, x2: _b.x2, y2: _b.y2 }, cells: [[0, 0], [1, 1], [2, 2]] });
    array_push(_all, { seg: { x1: _b.x1, y1: _b.y2, x2: _b.x2, y2: _b.y1 }, cells: [[0, 2], [1, 1], [2, 0]] });
    return _all;
}

/// call every Step: warn -> (Knight swings) -> cut -> gone
function scr_slashes_step()
{
    for (var i = array_length(slashes) - 1; i >= 0; i--)
    {
        var _sl = slashes[i];
        _sl.t++;

        if (_sl.state == "warn" && !_sl.swung && _sl.t >= _sl.charge - knight_swing_lead)
        {
            _sl.swung = true;
            scr_knight_swing();
        }

        if (_sl.state == "warn" && _sl.t >= _sl.charge)
        {
            _sl.state = "cut";
            _sl.t = 0;
            if (cut_sound != noone && get_timer() - last_cut_snd > 40000)
            {
                audio_play_sound(cut_sound, 1, false);
                last_cut_snd = get_timer();
            }
            if (!is_undefined(on_slash_cut)) on_slash_cut(_sl);
        }
        else if (_sl.state == "cut")
        {
            if (_sl.t <= hit_frames && instance_exists(obj_soul) && !obj_soul.invulnerable
                && scr_point_segment_distance(obj_soul.x, obj_soul.y, _sl.x1, _sl.y1, _sl.x2, _sl.y2) <= hit_half_width)
            {
                scr_soul_take_hit(slash_damage, hit_color_top, hit_color_bottom);
            }
            if (_sl.t >= cut_frames) array_delete(slashes, i, 1);
        }
    }
    scr_knight_swing_step();
}

/// the red fill on every sector a waiting cut will pass through. _b = the rect the 3x3 grid covers
function scr_slash_cells_draw(_b, _alpha_mult = 1)
{
    var _cw = (_b.x2 - _b.x1) / 3, _ch = (_b.y2 - _b.y1) / 3;
    for (var i = 0; i < array_length(slashes); i++)
    {
        var _sl = slashes[i];
        if (_sl.state != "warn" || array_length(_sl.cells) == 0) continue;
        var _k = clamp(_sl.t / _sl.charge, 0, 1);
        var _blink = (_sl.charge - _sl.t <= warn_blink) && ((_sl.t div 3) mod 2 == 0);
        draw_set_color(warn_color);
        draw_set_alpha(_alpha_mult * (_blink ? cell_alpha_max : cell_alpha_max * (0.25 + 0.6 * _k)));
        for (var c = 0; c < array_length(_sl.cells); c++)
        {
            var _cx = _b.x1 + _sl.cells[c][0] * _cw, _cy = _b.y1 + _sl.cells[c][1] * _ch;
            draw_rectangle(_cx + 2, _cy + 2, _cx + _cw - 2, _cy + _ch - 2, false);
        }
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// the warning lines and the cuts themselves
function scr_slashes_draw()
{
    for (var i = 0; i < array_length(slashes); i++)
    {
        var _sl = slashes[i];
        if (_sl.state == "warn")
        {
            // thin warning line, brighter as it charges, blinking right before the cut
            var _k = clamp(_sl.t / _sl.charge, 0, 1);
            var _blink = (_sl.charge - _sl.t <= warn_blink) && ((_sl.t div 3) mod 2 == 0);
            draw_set_color(_blink ? c_white : warn_color);
            draw_set_alpha(0.3 + 0.6 * _k);
            draw_line_width(_sl.x1, _sl.y1, _sl.x2, _sl.y2, 1 + _k);
        }
        else
        {
            // the cut: a bright line that thins out
            var _k = _sl.t / cut_frames;
            var _w = cut_width * (1 - _k);
            gpu_set_blendmode(bm_add);
            draw_set_color(warn_color);
            draw_set_alpha(0.6 * (1 - _k));
            draw_line_width(_sl.x1, _sl.y1, _sl.x2, _sl.y2, _w + 6);
            gpu_set_blendmode(bm_normal);
            draw_set_color(c_white);
            draw_set_alpha(1 - _k);
            draw_line_width(_sl.x1, _sl.y1, _sl.x2, _sl.y2, max(_w, 1));
        }
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}