if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
var _s = get_soul();
var _c = scr_box_center();

if (flash_t > 0) flash_t--;

if (mark_t > 0) mark_t--;

// --- colour change: wait for whoever's doing it ---
if (swapping)
{
    swap_el++;
	
    // red: the Knight starts his swing so it lands as the ring closes
    if (next_mode == "red" && !knight_swung && swap_el >= knight_swing_at)
    {
        knight_swung = true;
        scr_knight_swing();
    }

    // Susie's buster follows the soul until she actually throws it
    if (instance_exists(buster) && buster.state == "windup" && instance_exists(_s))
    {
        buster.target_x = _s.x;
        buster.target_y = _s.y;
    }

    if (swap_ready()) do_swap();
}

// Ralsei goes back to his battle idle once the spell's played out
if (ralsei_cast && instance_exists(obj_ralsei) && obj_ralsei.sprite_index == ralsei_cast_sprite && obj_ralsei.image_speed == 0)
{
    if (scr_party_is_up(obj_ralsei)) scr_set_battle_sprite(obj_ralsei, ralsei_idle_sprite, noone, true);
    ralsei_cast = false;
}

// --- green: slide to the middle, then the shield takes over ---
if (glide_t > 0 && instance_exists(_s))
{
    _s.x = lerp(_s.x, _c.x, 0.35);
    _s.y = lerp(_s.y, _c.y, 0.35);
    glide_t--;
    if (glide_t <= 0) _s.external_move = false;
}

// --- cuts ---
scr_slashes_step();

// --- swords ---
var _b = scr_get_attack_bounds();
for (var i = array_length(swords) - 1; i >= 0; i--)
{
    var _w = swords[i];
    _w.t++;
    _w.dist -= _w.speed;

    // fades in, then out once it's gone past the far wall
    var _horiz = (_w.side == 0 || _w.side == 2);
    var _half  = _horiz ? (_b.x2 - _b.x1) / 2 : (_b.y2 - _b.y1) / 2;
    var _past  = -_half - _w.dist; // how far the tip is beyond the far wall
    _w.alpha = min(_w.t / fade_in, 1) * clamp(1 - _past / fade_out_px, 0, 1);
    if (_past > fade_out_px + blade_len) { array_delete(swords, i, 1); continue; }

    if (!instance_exists(_s)) continue;

    // green soul + middle lane: the shield decides
    if (_s.soul_mode == "green" && abs(_w.lane) < 1 && _w.dist <= _s.shield_r + 2 && _w.dist > -_s.shield_r)
    {
        if (_s.shield_on && _s.shield_dir == _w.side)
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

    // anything else: the blade itself hurts
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
        // a "clear" beat holds here until nothing's left on screen, an "await" until the colour change lands
        if (bi > 0 && beats[bi - 1].act == "clear"
            && (array_length(swords) > 0 || array_length(slashes) > 0 || swapping || glide_t > 0)) break;
        if (bi > 0 && beats[bi - 1].act == "await" && (swapping || glide_t > 0)) break;

        timer--;
        if (timer > 0) break;

        if (bi >= array_length(beats)) { timer = end_delay; state = "end_wait"; break; }

        var _bt = beats[bi];
        switch (_bt.act)
        {
            case "mode":  start_swap(_bt.m); break;
            case "red":   spawn_red(_bt.p, _bt.charge); break;
            case "blue":  spawn_blue(_bt.n, _bt.charge); break;
            case "sword": spawn_sword(_bt.side, _bt.lane, _bt.spd); break;
            case "clear": break;
            case "await": break;
        }
        timer = _bt.wait;
        bi++;
    break;

    case "end_wait":
        timer--;
        if (timer <= 0) instance_destroy(); // sequencer clears the soul + closes the box
    break;
}