// the box only goes away on purpose (Susie breaking it); otherwise the attack's over
if (!instance_exists(obj_battlebox) && !fullscreen && !waiting_break) { instance_destroy(); exit; }
var _s = get_soul();
var _c = scr_box_center();

scr_soul_swap_step();
scr_slashes_step();
if (white_t > 0) white_t--;

// Susie's buster broke the box
if (waiting_break && (!instance_exists(buster) || buster.broken)) box_broken();

// the darkness once the box is gone, and the whole-screen grid while light blue
dim = fullscreen ? min(dim + 1 / dim_fade, 1) : 0;
var _blue_now = fullscreen && instance_exists(_s) && _s.soul_mode == "lightblue";
grid_fade = _blue_now ? min(grid_fade + 1 / 30, 1) : max(grid_fade - 1 / 30, 0);

// green can turn 8 ways once it's the whole screen
if (instance_exists(_s))
{
    _s.shield_dirs = fullscreen ? 8 : 4;
    _s.shield_arc  = fullscreen ? shield_arc_8 : 50;
}

// shards from the corners
for (var i = array_length(shards) - 1; i >= 0; i--)
{
    var _p = shards[i];
    _p.t++;
    _p.vy += 0.25;
    _p.x += _p.vx;
    _p.y += _p.vy;
    _p.rot += _p.vr;
    if (_p.t >= shard_life) array_delete(shards, i, 1);
}

// --- the dark corners: light blue can't go in them, and they hurt to touch ---
for (var k = 0; k < 9; k++) if (dark[k]) dark_t[k] = min(dark_t[k] + 1, dark_fade);
if (instance_exists(_s))
{
    for (var k = 0; k < 9; k++) _s.grid_blocked[k] = dark[k];

    if (_s.soul_mode != "green" && !_s.invulnerable)
    {
        var _l = scr_world_to_box_local(_s.x, _s.y);
        for (var k = 0; k < 9; k++)
        {
            if (!dark[k] || dark_t[k] < dark_fade) continue;
            var _r = cell_rect(k);
            if (_l.x > _r.x1 + dark_inset && _l.x < _r.x2 - dark_inset && _l.y > _r.y1 + dark_inset && _l.y < _r.y2 - dark_inset)
            {
                scr_soul_take_hit(dark_damage, hit_color_top, hit_color_bottom);
                break;
            }
        }
    }
}

// --- swords ---
var _b = scr_get_attack_bounds();
for (var i = array_length(swords) - 1; i >= 0; i--)
{
    var _w = swords[i];
    _w.t++;
    _w.dist -= _w.speed;

    var _horiz = (_w.side == 0 || _w.side == 2);
    var _half  = (_w.side == -1) ? min(_b.x2 - _b.x1, _b.y2 - _b.y1) / 2
               : (_horiz ? (_b.x2 - _b.x1) / 2 : (_b.y2 - _b.y1) / 2);
    var _past  = -_half - _w.dist;
    _w.alpha = min(_w.t / fade_in, 1) * clamp(1 - _past / fade_out_px, 0, 1);
    if (_past > fade_out_px + blade_len) { array_delete(swords, i, 1); continue; }

    if (!instance_exists(_s)) continue;

    if (_s.soul_mode == "green" && abs(_w.lane) < 1 && _w.dist <= _s.shield_r + 2 && _w.dist > -_s.shield_r)
    {
        var _facing = (_s.shield_dirs == 8) ? (_s.shield_dir == _w.d8) : (_s.shield_dir == _w.side);
        if (_s.shield_on && _facing)
        {
            audio_play_sound(block_sound, 1, false);
            array_push(sparks, { x: _c.x + lengthdir_x(_s.shield_r, _w.ang), y: _c.y + lengthdir_y(_s.shield_r, _w.ang), ang: _w.ang, t: 0 });
        }
        else
        {
            scr_soul_take_hit(sword_damage, hit_color_top, hit_color_bottom);
        }
        array_delete(swords, i, 1);
        continue;
    }

    if (_s.soul_mode != "green" && _w.alpha > 0.5 && !_s.invulnerable)
    {
        var _tip = sword_tip(_w, _c);
        var _bx = _tip.x + lengthdir_x(blade_len, _w.ang), _by = _tip.y + lengthdir_y(blade_len, _w.ang);
        if (scr_point_segment_distance(_s.x, _s.y, _tip.x, _tip.y, _bx, _by) <= sword_hit_r)
        {
            scr_soul_take_hit(sword_damage, hit_color_top, hit_color_bottom);
        }
    }
}

for (var i = array_length(sparks) - 1; i >= 0; i--)
{
    sparks[i].t++;
    if (sparks[i].t >= spark_frames) array_delete(sparks, i, 1);
}

// --- the script ---
switch (state)
{
    case "intro":
        if (scr_box_scale_settled()) timer--;
        if (timer <= 0) { bi = 0; timer = 0; state = "run"; }
    break;

    case "run":
        if (bi > 0 && beats[bi - 1].act == "clear"
            && (array_length(swords) > 0 || array_length(slashes) > 0 || scr_soul_swap_busy())) break;
        if (bi > 0 && beats[bi - 1].act == "await" && scr_soul_swap_busy()) break;
        if (bi > 0 && beats[bi - 1].act == "flash" && white_t > 0) break;
        if (bi > 0 && beats[bi - 1].act == "buster" && !fullscreen) break;
        if (green_hold > 0 && !scr_soul_swap_busy()) { green_hold--; break; } // the extra second after light blue -> green

        timer--;
        if (timer > 0) break;

        if (bi >= array_length(beats)) { timer = end_delay; state = "end_wait"; break; }

        var _bt = beats[bi];
        switch (_bt.act)
        {
            case "mode":
                if (_bt.m == "green" && instance_exists(_s) && _s.soul_mode == "lightblue") green_hold = green_extra;
                scr_soul_swap_start(_bt.m);
            break;
            case "red":    spawn_red(_bt.p, _bt.charge); break;
            case "blue":   spawn_blue(_bt.n, _bt.charge); break;
            case "sword":  spawn_sword(_bt.side, _bt.lane, _bt.spd); break;
            case "shrink": shrink_box(_bt.s); break;
            case "corner": darken_corner(); break;
            case "x":      spawn_x(); break;
            case "buster": start_buster(); break;
            case "sword8": spawn_sword8(_bt.how, _bt.spd); break;
            case "flash":
                white_t = flash_frames;
                audio_play_sound(snd_glassbreak, 1, false);
                scr_camera_shake(6, 30);
            break;
            case "await":  break;
            case "clear":  break;
        }
        timer = _bt.wait;
        bi++;
    break;

    case "end_wait":
        timer--;
        if (timer <= 0) instance_destroy(); // sequencer clears the soul + closes the box
    break;
}