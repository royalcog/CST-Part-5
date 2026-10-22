if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") { instance_destroy(); exit; } // Clean Up puts the box + soul back together

var _in   = scr_get_box_interior();
var _half = sprite_get_width(spr_roaringknight_sword) * sword_scale / 2;

// lock the seam in place once the box is cut
if (!split_active)
{
    var _c = scr_box_center();
    seam_x = _c.x;
    seam_y = _c.y;
}

// --- the halves sliding + carrying the soul ---
if (split_active)
{
    slide_t++;
    if (state == "merge") slide_k = max(slide_k - 1 / merge_frames, 0);
    else                  slide_k = min(slide_k + 1 / slide_ramp, 1);

    var _o = slide_dir * slide_amp * slide_k * sin(slide_t / slide_period * 2 * pi);
    off_a =  _o;
    off_b = -_o;
    obj_battlebox.split_off_a = off_a;
    obj_battlebox.split_off_b = off_b;

    seam_flash = max(seam_flash - seam_flash_fade, 0);

    if (instance_exists(obj_soul))
    {
        // the soul moves in the un-split box; each piece is drawn shifted by its own half
        var _spd = obj_soul.move_speed;
        soul_lx += (keyboard_check(vk_right) - keyboard_check(vk_left)) * _spd;
        soul_ly += (keyboard_check(vk_down)  - keyboard_check(vk_up))   * _spd;

        var _mx = obj_soul.sprite_width  / 2;
        var _my = obj_soul.sprite_height / 2;
        soul_lx = clamp(soul_lx, _in.x1 + _mx, _in.x2 - _mx);
        soul_ly = clamp(soul_ly, _in.y1 + _my, _in.y2 - _my);

        // obj_soul's own x/y = wherever its center is (damage popups etc. use this)
        if (split_axis == "h")
        {
            obj_soul.x = soul_lx + ((soul_ly < seam_y) ? off_a : off_b);
            obj_soul.y = soul_ly;
        }
        else
        {
            obj_soul.x = soul_lx;
            obj_soul.y = soul_ly + ((soul_lx < seam_x) ? off_a : off_b);
        }
    }
}

// --- phases ---
switch (state)
{
    case "intro":
        if (scr_box_scale_settled()) timer--;
        if (timer <= 0)
        {
            var _off   = _half + side_gap;
            var _start = choose(true, false);
            cut_sword = { x: 0, y: 0, angle: 0, t: 0, alpha: 0, state: "charge",
                          vx: 0, vy: 0, trail: [], travelled: 0, travel_max: 0, cut_at: 0 };

            if (split_axis == "h")
            {
                cut_sword.y     = seam_y;
                cut_sword.x     = _start ? _in.x1 - _off : _in.x2 + _off;
                cut_sword.angle = _start ? 0 : 180;
                cut_sword.cut_at     = abs(seam_x - cut_sword.x);
                cut_sword.travel_max = (_in.x2 - _in.x1) + _off * 2 + _half * 2 + 40;
            }
            else
            {
                cut_sword.x     = seam_x;
                cut_sword.y     = _start ? _in.y1 - _off : _in.y2 + _off;
                cut_sword.angle = _start ? 270 : 90;
                cut_sword.cut_at     = abs(seam_y - cut_sword.y);
                cut_sword.travel_max = (_in.y2 - _in.y1) + _off * 2 + _half * 2 + 40;
            }
            state = "cut";
        }
    break;

    case "cut":
        // waits for the cutting sword to reach the middle (below)
    break;

    case "slashes":
        if (spawned < slash_count)
        {
            timer--;
            if (timer <= 0)
            {
                var _p = spawned / max(slash_count - 1, 1);

                // a different side than last time
                var _side = irandom(3);
                if (_side == last_side) _side = (_side + 1 + irandom(2)) mod 4;
                last_side = _side;

                // the sides the halves slide toward need extra room
                var _offx = _half + side_gap + ((split_axis == "h") ? slide_amp : 0);
                var _offy = _half + side_gap + ((split_axis == "v") ? slide_amp : 0);

                var _wspd = lerp(wave_speed, wave_speed_end, _p);
                var _s = { x: 0, y: 0, angle: 0, draw_angle: 0, t: 0, alpha: 0, state: "charge",
                           charge: round(lerp(slash_charge, slash_charge_end, _p)),
                           swing_t: 0, swing_sign: choose(-1, 1), trail: [], wspd: _wspd };

                switch (_side)
                {
                    case 0: _s.x = _in.x1 - _offx; _s.y = random_range(_in.y1, _in.y2); break; // left
                    case 1: _s.x = _in.x2 + _offx; _s.y = random_range(_in.y1, _in.y2); break; // right
                    case 2: _s.y = _in.y1 - _offy; _s.x = random_range(_in.x1, _in.x2); break; // top
                    case 3: _s.y = _in.y2 + _offy; _s.x = random_range(_in.x1, _in.x2); break; // bottom
                }

                var _tx = instance_exists(obj_soul) ? obj_soul.x : seam_x;
                var _ty = instance_exists(obj_soul) ? obj_soul.y : seam_y;
                _s.angle      = point_direction(_s.x, _s.y, _tx, _ty);
                _s.draw_angle = _s.angle;

                array_push(swords, _s);
                spawned++;
                timer = round(lerp(slash_gap, slash_gap_end, _p));
            }
        }
        else if (array_length(swords) == 0 && array_length(waves) == 0 && cut_sword == undefined)
        {
            state = "merge";
        }
    break;

    case "merge":
        if (slide_k <= 0) { instance_destroy(); exit; }
    break;
}

// --- the cutting sword ---
if (cut_sword != undefined)
{
    var _s = cut_sword;
    if (_s.state == "charge")
    {
        _s.t++;
        _s.alpha = min(_s.alpha + 1 / fade_in_frames, 1);
        if (_s.t >= cut_charge)
        {
            _s.vx = lengthdir_x(cut_speed, _s.angle);
            _s.vy = lengthdir_y(cut_speed, _s.angle);
            _s.state = "fly";
            audio_play_sound(cut_sound, 1, false);
        }
    }
    else
    {
        array_insert(_s.trail, 0, { x: _s.x, y: _s.y });
        if (array_length(_s.trail) > cut_trail_len) array_pop(_s.trail);

        var _px = _s.x;
        var _py = _s.y;
        _s.x += _s.vx;
        _s.y += _s.vy;
        _s.travelled += cut_speed;

        if (instance_exists(obj_soul) && !obj_soul.invulnerable)
        {
            var _hx = lengthdir_x(_half, _s.angle);
            var _hy = lengthdir_y(_half, _s.angle);
            if (touches_soul(_px - _hx, _py - _hy, _s.x + _hx, _s.y + _hy, hit_radius))
            {
                scr_soul_take_hit(damage, hit_color_top, hit_color_bottom);
            }
        }

        if (!split_active && _s.travelled >= _s.cut_at) split_now();
        if (_s.travelled >= _s.travel_max) cut_sword = undefined;
    }
}

// --- slash swords ---
for (var i = array_length(swords) - 1; i >= 0; i--)
{
    var _s = swords[i];

    switch (_s.state)
    {
        case "charge":
            _s.t++;
            _s.alpha = min(_s.alpha + 1 / fade_in_frames, 1);

            var _k = _s.t / _s.charge;
            if (_k < track_stop && instance_exists(obj_soul))
            {
                var _want = point_direction(_s.x, _s.y, obj_soul.x, obj_soul.y);
                _s.angle += angle_difference(_want, _s.angle) * track_lerp;
            }

            // winds back for the swing once it stops aiming
            var _wind = clamp((_k - track_stop) / (1 - track_stop), 0, 1);
            _s.draw_angle = _s.angle - (swing_arc / 2) * _wind * _s.swing_sign;

            if (_s.t >= _s.charge)
            {
                // the wave heads for wherever the soul is right now
                var _tx  = instance_exists(obj_soul) ? obj_soul.x : seam_x;
                var _ty  = instance_exists(obj_soul) ? obj_soul.y : seam_y;
                var _dir = point_direction(_s.x, _s.y, _tx, _ty);
                var _wx  = _s.x + lengthdir_x(_half, _dir);
                var _wy  = _s.y + lengthdir_y(_half, _dir);

                array_push(waves, { x: _wx, y: _wy, dir: _dir, spd: _s.wspd, travelled: 0,
                                    travel_max: point_distance(_wx, _wy, _tx, _ty) + 300, trail: [] });

                _s.state   = "swing";
                _s.swing_t = 0;
                audio_play_sound(slash_sound, 1, false);
            }
        break;

        case "swing":
            array_insert(_s.trail, 0, _s.draw_angle);
            if (array_length(_s.trail) > 4) array_pop(_s.trail);

            _s.swing_t++;
            var _e = 1 - power(1 - clamp(_s.swing_t / swing_frames, 0, 1), 3);
            _s.draw_angle = _s.angle - (swing_arc / 2) * _s.swing_sign + swing_arc * _s.swing_sign * _e;
            if (_s.swing_t >= swing_frames) _s.state = "fade";
        break;

        case "fade":
            if (array_length(_s.trail) > 0) array_pop(_s.trail);
            _s.alpha -= 1 / fade_in_frames;
            if (_s.alpha <= 0) { array_delete(swords, i, 1); continue; }
        break;
    }
}

// --- waves of light ---
for (var i = array_length(waves) - 1; i >= 0; i--)
{
    var _w = waves[i];

    array_insert(_w.trail, 0, { x: _w.x, y: _w.y });
    if (array_length(_w.trail) > wave_trail) array_pop(_w.trail);

    _w.x += lengthdir_x(_w.spd, _w.dir);
    _w.y += lengthdir_y(_w.spd, _w.dir);
    _w.travelled += _w.spd;

	if (instance_exists(obj_soul) && !obj_soul.invulnerable && wave_touches_soul(_w))
    {
        scr_soul_take_hit(wave_damage, hit_color_top, hit_color_bottom);
    }

    if (_w.travelled >= _w.travel_max) array_delete(waves, i, 1);
}