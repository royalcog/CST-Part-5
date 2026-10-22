/// where the 3 rows and 3 columns are on screen right now (box turned in 90° steps)
function scr_knight_lanes()
{
    // no box (Susie broke it): the whole screen is the grid
    if (!instance_exists(obj_battlebox) || !obj_battlebox.visible)
    {
        var _b  = scr_get_attack_bounds();
        var _sw = _b.x2 - _b.x1, _sh = _b.y2 - _b.y1;
        var _cx = (_b.x1 + _b.x2) / 2, _cy = (_b.y1 + _b.y2) / 2;
        return { cx: _cx, cy: _cy, hx: _sw / 2, hy: _sh / 2,
                 xs: [_cx - _sw / 3, _cx, _cx + _sw / 3],
                 ys: [_cy - _sh / 3, _cy, _cy + _sh / 3] };
    }
    var _in  = scr_get_box_interior();
    var _c   = scr_box_center();
    var _iw  = _in.x2 - _in.x1, _ih = _in.y2 - _in.y1;
    var _odd = instance_exists(obj_battlebox) && ((round(obj_battlebox.box_angle / 90) mod 2) != 0);
    var _w   = _odd ? _ih : _iw;
    var _h   = _odd ? _iw : _ih;
    return { cx: _c.x, cy: _c.y, hx: _w / 2, hy: _h / 2,
             xs: [_c.x - _w / 3, _c.x, _c.x + _w / 3],
             ys: [_c.y - _h / 3, _c.y, _c.y + _h / 3] };
}

/// which lane (0-2) _v is closest to
function scr_knight_lane_index(_vals, _v)
{
    var _best = 0;
    for (var i = 1; i < 3; i++) if (abs(_vals[i] - _v) < abs(_vals[_best] - _v)) _best = i;
    return _best;
}

/// a sword waiting just outside the box. _side: 0 left, 1 right, 2 top, 3 bottom. _lane: 0-2
function scr_spawn_lane_sword(_side, _lane, _charge)
{
    var _L = scr_knight_lanes();
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : (instance_exists(obj_soul) ? obj_soul.depth + 1 : -5001);
    var _s = instance_create_depth(0, 0, _d, obj_knight_lane_sword);
    var _off = _s.half + _s.side_gap;

    switch (_side)
    {
        case 0: _s.x = _L.cx - _L.hx - _off; _s.y = _L.ys[_lane]; _s.dir = 0;   break;
        case 1: _s.x = _L.cx + _L.hx + _off; _s.y = _L.ys[_lane]; _s.dir = 180; break;
        case 2: _s.y = _L.cy - _L.hy - _off; _s.x = _L.xs[_lane]; _s.dir = 270; break;
        case 3: _s.y = _L.cy + _L.hy + _off; _s.x = _L.xs[_lane]; _s.dir = 90;  break;
    }
    _s.travel_max = ((_side < 2) ? _L.hx : _L.hy) * 2 + _off * 2 + _s.half * 2 + 40;
    _s.charge = _charge;
    return _s;
}

/// _n swords at once. the first one is always on the soul's lane, and they never cover
/// all 3 rows or all 3 columns, so there's always at least one safe section
function scr_spawn_lane_volley(_n, _charge)
{
    var _L = scr_knight_lanes();
    var _rows = [], _cols = [], _used = [];

    for (var i = 0; i < _n; i++)
    {
        var _ok = false, _side = 0, _lane = 0;
        repeat (30)
        {
            _side = irandom(3);
            var _horiz = (_side < 2);
            if (i == 0 && instance_exists(obj_soul))
                _lane = _horiz ? scr_knight_lane_index(_L.ys, obj_soul.y) : scr_knight_lane_index(_L.xs, obj_soul.x);
            else
                _lane = irandom(2);

            if (array_contains(_used, string(_side) + ":" + string(_lane))) continue;
            var _set = _horiz ? _rows : _cols;
            if (!array_contains(_set, _lane) && array_length(_set) >= 2) continue;
            _ok = true;
            break;
        }
        if (!_ok) continue;

        array_push(_used, string(_side) + ":" + string(_lane));
        if (_side < 2) { if (!array_contains(_rows, _lane)) array_push(_rows, _lane); }
        else           { if (!array_contains(_cols, _lane)) array_push(_cols, _lane); }

        scr_spawn_lane_sword(_side, _lane, _charge + i * 4);
    }
}

/// first point where a moving sword tip runs into Susie's barrier (undefined if it doesn't)
function scr_barrier_hit_segment(_ax, _ay, _bx, _by)
{
    if (!instance_exists(obj_susie_barrier)) return undefined;
    var _n = max(1, ceil(point_distance(_ax, _ay, _bx, _by) / 6));
    for (var i = 0; i <= _n; i++)
    {
        var _px = lerp(_ax, _bx, i / _n), _py = lerp(_ay, _by, i / _n);
        var _hit = false;
        with (obj_susie_barrier) if (active && point_in_rectangle(_px, _py, x1, y1, x2, y2)) _hit = true;
        if (_hit) return { x: _px, y: _py };
    }
    return undefined;
}

function scr_soul_in_barrier()
{
    if (!instance_exists(obj_soul)) return false;
    var _sx = obj_soul.x, _sy = obj_soul.y, _in = false;
    with (obj_susie_barrier) if (active && point_in_rectangle(_sx, _sy, x1, y1, x2, y2)) _in = true;
    return _in;
}