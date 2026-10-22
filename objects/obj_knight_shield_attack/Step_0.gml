if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (!instance_exists(soul)) soul = instance_exists(obj_soul) ? instance_find(obj_soul, 0) : noone;

if (flash_t > 0) flash_t--;

// Ralsei goes back to his battle idle once the spell's played out
if (ralsei_cast && instance_exists(obj_ralsei) && obj_ralsei.sprite_index == ralsei_cast_sprite && obj_ralsei.image_speed == 0)
{
    if (scr_party_is_up(obj_ralsei)) scr_set_battle_sprite(obj_ralsei, ralsei_idle_sprite, noone, true);
    ralsei_cast = false;
}

// --- swords ---
var _c = scr_box_center();
for (var i = array_length(swords) - 1; i >= 0; i--)
{
    var _w = swords[i];
    _w.t++;

    if (_w.feint && _w.spin_t < 0 && _w.dist <= feint_at)
    {
        _w.spin_t   = 0;
        _w.from_ang = _w.ang;
        audio_play_sound(snd_smallswing, 1, false);
    }

    if (_w.spin_t >= 0 && _w.spin_t < feint_spin_frames)
    {
        // whips around the soul to the opposite side (holds its distance while it turns)
        _w.spin_t++;
        var _k = _w.spin_t / feint_spin_frames;
        _w.ang = _w.from_ang + 180 * (1 - power(1 - _k, 2));
    }
    else
    {
        _w.dist -= _w.speed;
    }

    if (instance_exists(soul) && _w.dist <= soul.shield_r + 2)
    {
        var _side = ((round(_w.ang / 90) mod 4) + 4) mod 4;
        var _px = _c.x + lengthdir_x(soul.shield_r, _w.ang), _py = _c.y + lengthdir_y(soul.shield_r, _w.ang);
        if (soul.shield_on && soul.shield_dir == _side)
        {
            audio_play_sound(block_sound, 1, false);
            array_push(sparks, { x: _px, y: _py, ang: _w.ang, t: 0 });
        }
        else
        {
            scr_soul_take_hit(sword_damage, hit_color_top, hit_color_bottom);
        }
        array_delete(swords, i, 1);
    }
}

for (var i = array_length(sparks) - 1; i >= 0; i--)
{
    sparks[i].t++;
    if (sparks[i].t >= spark_frames) array_delete(sparks, i, 1);
}

switch (state)
{
    case "intro":
        if (scr_box_scale_settled()) timer--;
        if (timer <= 0)
        {
            obj_battlebox.target_scale_x = box_scale;
            obj_battlebox.target_scale_y = box_scale;
            if (instance_exists(soul)) soul.external_move = true;
            state = "shrink";
        }
    break;
	
	case "shrink":
        if (instance_exists(soul))
        {
            soul.x = lerp(soul.x, _c.x, glide_lerp);
            soul.y = lerp(soul.y, _c.y, glide_lerp);
        }
        if (scr_box_scale_settled())
        {
            if (ralsei_up())
            {
                scr_set_battle_sprite(obj_ralsei, ralsei_cast_sprite, noone, false);
                ralsei_cast = true;
                if (cast_sound != noone) audio_play_sound(cast_sound, 1, false);
            }
            shake_x = _c.x;
            shake_y = _c.y;
            timer = shake_frames;
            state = "cast";
        }
    break;

    // the soul shakes while he casts, and turns green the moment his spell goes off (cast_frame)
    case "cast":
        if (!instance_exists(soul)) { instance_destroy(); exit; }

        var _casting = ralsei_cast && instance_exists(obj_ralsei) && obj_ralsei.sprite_index == ralsei_cast_sprite
                       && obj_ralsei.image_speed != 0;
        var _k = _casting ? clamp(obj_ralsei.image_index / cast_frame, 0, 1) : 1 - max(timer, 0) / shake_frames;
        soul.x = shake_x + random_range(-shake_amount, shake_amount) * (0.4 + 0.6 * _k);
        soul.y = shake_y + random_range(-shake_amount, shake_amount) * (0.4 + 0.6 * _k);

        // no cast to wait on (Ralsei's down / got hurt): fall back to a plain timer
        timer--;
        var _fired = _casting ? (floor(obj_ralsei.image_index) >= cast_frame) : (timer <= 0);

        if (_fired)
        {
            soul.x = shake_x;
            soul.y = shake_y;
            scr_soul_set_mode(soul, "green");
            soul.external_move = false;
            soul.shield_on  = true;
            soul.shield_pop = 0;
            if (change_sound != noone) audio_play_sound(change_sound, 1, false, change_gain);
            flash_t = flash_frames;
            flash_x = shake_x;
            flash_y = shake_y;
            scr_camera_shake(2, 8);
            timer = learn_delay;
            state = "learn";
        }
    break;

    case "learn":
        timer--;
        if (timer <= 0) { wi = 0; spawned = 0; timer = 0; state = "wave"; }
    break;

    case "wave":
        var _wv = waves[wi];
        timer--;
        if (spawned == 0 && _wv.pattern == "spin" && timer <= 0)
        {
            spin_side = irandom(3);
            spin_step = choose(1, -1);
        }
        if (timer <= 0 && spawned < _wv.count)
        {
            var _feint = random(1) < _wv.feint;
            spawn_sword(pick_side(_wv.pattern), _wv.speed, _feint);
            spawned++;
            timer = _wv.gap + (_feint ? feint_spin_frames : 0); // the turn delays it, so the next one waits too
        }
        if (spawned >= _wv.count && array_length(swords) == 0)
        {
            wi++;
            if (wi < array_length(waves)) { spawned = 0; timer = wave_gap; }
            else { timer = end_delay; state = "end_wait"; }
        }
    break;

    case "end_wait":
        timer--;
        if (timer <= 0) instance_destroy(); // sequencer clears the soul + closes the box
    break;
}