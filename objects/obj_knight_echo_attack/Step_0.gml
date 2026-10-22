if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
var _s = get_soul();
var _c = scr_box_center();

scr_soul_swap_step();
scr_slashes_step();

// --- remember where the soul's been ---
if ((state == "red" || state == "blue" || state == "to_green") && instance_exists(_s))
{
    array_push(history, { x: _s.x, y: _s.y });
    if (array_length(history) > history_cap) array_delete(history, 0, 1);
}

// --- echoes replay the path ---
for (var i = array_length(echoes) - 1; i >= 0; i--)
{
    var _e = echoes[i];
    if (_e.dying)
    {
        _e.die_t++;
        _e.alpha = min(_e.alpha, 1 - _e.die_t / echo_fade_out);
        if (_e.alpha <= 0) array_delete(echoes, i, 1);
        continue;
    }

    var _p = history_at(_e.delay);
    if (is_undefined(_p)) continue; // hasn't been that long yet
    _e.x = _p.x;
    _e.y = _p.y;
    _e.t++;
    _e.alpha = min(_e.t / echo_fade_in, 1);

    if (_e.alpha >= 1 && instance_exists(_s) && !_s.invulnerable
        && point_distance(_e.x, _e.y, _s.x, _s.y) <= echo_hit_r)
    {
        scr_soul_take_hit(echo_damage, hit_color_top, hit_color_bottom);
    }
}

// --- green finale echoes ---
for (var i = array_length(finale) - 1; i >= 0; i--)
{
    var _f = finale[i];
    _f.t++;
    switch (_f.state)
    {
        case "appear":
            _f.alpha = min(_f.t / finale_appear, 1);
            if (_f.t >= finale_appear) { _f.state = "slide"; _f.t = 0; }
        break;

        case "slide":
        {
            // onto its side, in a line with the others there
            var _k  = 1 - power(1 - min(_f.t / finale_slide, 1), 2);
            var _tx = _c.x + lengthdir_x(_f.r, _f.side * 90), _ty = _c.y + lengthdir_y(_f.r, _f.side * 90);
            _f.x = lerp(_f.sx, _tx, _k);
            _f.y = lerp(_f.sy, _ty, _k);
            if (_f.t >= finale_slide) { _f.state = "wait"; _f.t = 0; }
        }
        break;

        case "fly":
            _f.dist -= _f.speed;
            _f.x = _c.x + lengthdir_x(_f.dist, _f.side * 90);
            _f.y = _c.y + lengthdir_y(_f.dist, _f.side * 90);
            if (instance_exists(_s) && _f.dist <= _s.shield_r + 2)
            {
                if (_s.soul_mode == "green" && _s.shield_on && _s.shield_dir == _f.side)
                {
                    audio_play_sound(block_sound, 1, false);
                    array_push(sparks, { x: _c.x + lengthdir_x(_s.shield_r, _f.side * 90), y: _c.y + lengthdir_y(_s.shield_r, _f.side * 90),
                                         ang: _f.side * 90, t: 0 });
                }
                else
                {
                    scr_soul_take_hit(echo_damage, hit_color_top, hit_color_bottom);
                }
                array_delete(finale, i, 1);
            }
        break;
    }
}

for (var i = array_length(sparks) - 1; i >= 0; i--)
{
    sparks[i].t++;
    if (sparks[i].t >= spark_frames) array_delete(sparks, i, 1);
}

// --- phases ---
switch (state)
{
    case "intro":
        if (scr_box_scale_settled()) timer--;
        if (timer <= 0) { scr_soul_swap_start("red"); state = "to_red"; }
    break;

    case "to_red":
        if (!scr_soul_swap_busy()) { history = []; phase_t = 0; next_cut = red_cut_first; state = "red"; }
    break;

    // RED: echoes follow you around the box, the Knight cuts through you to keep you moving
    case "red":
        add_echoes(red_echoes);
        phase_t++;
        if (phase_t >= next_cut && phase_t < red_len - red_cut_charge)
        {
            cut_red(red_cut_charge);
            next_cut += red_cut_gap;
        }
        if (phase_t >= red_len && array_length(slashes) == 0)
        {
            kill_echoes();
            scr_soul_swap_start("lightblue"); // Susie
            state = "to_blue";
        }
    break;

    case "to_blue":
        if (!scr_soul_swap_busy()) { history = []; echoes = []; phase_t = 0; next_cut = blue_cut_first; state = "blue"; }
    break;

    // LIGHT BLUE: echoes hop the grid behind you
    case "blue":
        add_echoes(blue_echoes);
        phase_t++;
        if (phase_t >= next_cut && phase_t < blue_len - blue_cut_charge)
        {
            cut_blue(blue_cut_charge);
            next_cut += blue_cut_gap;
        }
        if (phase_t >= blue_len && array_length(slashes) == 0)
        {
            scr_soul_swap_start("green"); // Ralsei (the echoes keep chasing you while he casts)
            state = "to_green";
        }
    break;

    // the moment the shield's up, every place you've been comes back
    case "to_green":
        if (!scr_soul_swap_busy())
        {
            build_finale();
            kill_echoes();
            timer = finale_appear + finale_slide + finale_hold;
            state = "finale";
        }
    break;

    case "finale":
        timer--;
        if (timer <= 0 && fi < finale_count)
        {
            // throw the next one still waiting (closest first on each side, so they don't pass through each other)
            var _pick = -1;
            for (var i = 0; i < array_length(finale); i++)
            {
                if (finale[i].state == "wait") { _pick = i; break; }
            }
            if (_pick != -1)
            {
                var _k = fi / max(finale_count - 1, 1);
                finale[_pick].state = "fly";
                finale[_pick].speed = lerp(finale_speed_a, finale_speed_b, _k);
                audio_play_sound(snd_smallswing, 1, false);
                timer = round(lerp(finale_gap_a, finale_gap_b, _k));
                fi++;
            }
            else
            {
                fi = finale_count; // nothing left waiting
            }
        }
        // done once every echo has been blocked or has hit
        if (array_length(finale) == 0) { timer = end_delay; state = "end_wait"; }
    break;

    case "end_wait":
        timer--;
        if (timer <= 0) instance_destroy(); // sequencer clears the soul + closes the box
    break;
}