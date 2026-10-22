if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

var _in      = scr_get_box_interior();
var _closing = (obj_battlebox.state == "closing");
var _half    = sprite_get_width(spr_roaringknight_sword) * sword_scale / 2;

// --- spawn ---
if (!_closing && spawned < sword_count && scr_box_scale_settled())
{
    timer--;
    if (timer <= 0)
    {
        var _off  = _half + side_gap;
        var _cx   = (_in.x1 + _in.x2) / 2;
        var _cy   = (_in.y1 + _in.y2) / 2;
        var _sx   = instance_exists(obj_soul) ? obj_soul.x : _cx;
        var _sy   = instance_exists(obj_soul) ? obj_soul.y : _cy;
        // 0 on the first sword -> 1 on the last, everything speeds up along this
        var _p    = spawned / max(sword_count - 1, 1);
        var _s    = { x: 0, y: 0, angle: 0, horizontal: true, state: "charge", t: 0, alpha: 0,
                      vx: 0, vy: 0, trail: [], travelled: 0, travel_max: 0,
                      charge: round(lerp(charge_frames, charge_frames_end, _p)),
                      track:  lerp(track_lerp, track_lerp_end, _p) };

                _s.diagonal = (random(1) < diagonal_chance);

        if (_s.diagonal)
        {
            // flies across the box at 45°, starting off the opposite corner
            _s.angle  = choose(45, 135, 225, 315);
            _s.cx     = _cx;
            _s.cy     = _cy;
            _s.radius = point_distance(_cx, _cy, _in.x2, _in.y2) + _off;

            // sideways offset from the box's center line, lined up with the soul to start
            var _pdx = lengthdir_x(1, _s.angle + 90);
            var _pdy = lengthdir_y(1, _s.angle + 90);
            _s.perp  = (_sx - _cx) * _pdx + (_sy - _cy) * _pdy;

            _s.x = _cx - lengthdir_x(_s.radius, _s.angle) + _pdx * _s.perp;
            _s.y = _cy - lengthdir_y(_s.radius, _s.angle) + _pdy * _s.perp;

            _s.travel_max = _s.radius * 2 + _half * 2 + 40;
        }
        else
        {
            switch (irandom(3))
            {
                case 0: _s.x = _in.x1 - _off; _s.y = clamp(_sy, _in.y1, _in.y2); _s.angle = 0;   _s.horizontal = true;  break; // left, points right
                case 1: _s.x = _in.x2 + _off; _s.y = clamp(_sy, _in.y1, _in.y2); _s.angle = 180; _s.horizontal = true;  break; // right, points left
                case 2: _s.y = _in.y1 - _off; _s.x = clamp(_sx, _in.x1, _in.x2); _s.angle = 270; _s.horizontal = false; break; // top, points down
                case 3: _s.y = _in.y2 + _off; _s.x = clamp(_sx, _in.x1, _in.x2); _s.angle = 90;  _s.horizontal = false; break; // bottom, points up
            }

            // far enough to clear the box and the other side completely
            _s.travel_max = (_s.horizontal ? (_in.x2 - _in.x1) : (_in.y2 - _in.y1)) + _off * 2 + _half * 2 + 40;
        }

        array_push(swords, _s);
        spawned++;
        timer = round(lerp(spawn_gap, spawn_gap_end, _p));
    }
}

// --- update ---
for (var i = array_length(swords) - 1; i >= 0; i--)
{
    var _s = swords[i];

    if (_s.state == "charge")
    {
        if (_closing)
        {
            _s.alpha -= 1 / fade_in_frames;
            if (_s.alpha <= 0) { array_delete(swords, i, 1); continue; }
        }
        else
        {
            _s.t++;
            _s.alpha = min(_s.alpha + 1 / fade_in_frames, 1);

            // slide to line up with the soul, until it's nearly fully red
            if (_s.t / _s.charge < track_stop && instance_exists(obj_soul))
            {
                if (_s.diagonal)
                {
                    // slide sideways so its flight line passes through the soul
                    var _pdx = lengthdir_x(1, _s.angle + 90);
                    var _pdy = lengthdir_y(1, _s.angle + 90);
                    var _target = (obj_soul.x - _s.cx) * _pdx + (obj_soul.y - _s.cy) * _pdy;
                    _s.perp = lerp(_s.perp, _target, _s.track);
                    _s.x = _s.cx - lengthdir_x(_s.radius, _s.angle) + _pdx * _s.perp;
                    _s.y = _s.cy - lengthdir_y(_s.radius, _s.angle) + _pdy * _s.perp;
                }
                else if (_s.horizontal) _s.y = lerp(_s.y, clamp(obj_soul.y, _in.y1, _in.y2), _s.track);
                else                    _s.x = lerp(_s.x, clamp(obj_soul.x, _in.x1, _in.x2), _s.track);
            }

            if (_s.t >= _s.charge)
            {
                _s.vx = lengthdir_x(launch_speed, _s.angle);
                _s.vy = lengthdir_y(launch_speed, _s.angle);
                _s.state = "fly";
                audio_play_sound(snd_knight_cut, 1, false);
            }
        }
    }
    else if (_s.state == "fly")
    {
        array_insert(_s.trail, 0, { x: _s.x, y: _s.y });
        if (array_length(_s.trail) > trail_len) array_pop(_s.trail);

        var _px = _s.x;
        var _py = _s.y;
        _s.x += _s.vx;
        _s.y += _s.vy;
        _s.travelled += launch_speed;

        // check the whole stretch the blade swept this frame, so it can't skip over the soul at this speed
        if (instance_exists(obj_soul) && !obj_soul.invulnerable)
        {
            var _hx = lengthdir_x(_half, _s.angle);
            var _hy = lengthdir_y(_half, _s.angle);
            if (scr_point_segment_distance(obj_soul.x, obj_soul.y, _px - _hx, _py - _hy, _s.x + _hx, _s.y + _hy) <= hit_radius)
            {
                scr_soul_take_hit(damage, c_white, c_white);
            }
        }

        if (_s.travelled >= _s.travel_max) { array_delete(swords, i, 1); continue; }
    }
}

// done once every sword has been thrown and cleared (or the box closed under them)
if ((spawned >= sword_count || _closing) && array_length(swords) == 0)
{
    instance_destroy();
}