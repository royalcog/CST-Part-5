t++;
var _sec = t / fps_;
var _cam = view_camera[0];
var _vx  = camera_get_view_x(_cam);
var _vy  = camera_get_view_y(_cam);
var _vh  = camera_get_view_height(_cam);
var _sy  = _vy - 60;   // where the beam starts, off the top of the screen

flash = max(0, flash - 1 / (flash_time * fps_));
if (beam_on) beam_t++;

// ---------------------------------------------------------------- the shield goes up, the beam hits it
if (_sec >= react_at && once("react") && instance_exists(ralsei))
{
    ralsei.sprite_index = ralsei_react_sprite;
    ralsei.image_index  = 0;
    ralsei.image_speed  = 0;
}
if (_sec >= cast_at && once("cast") && instance_exists(ralsei))
{
    ralsei.sprite_index = ralsei_cast_sprite;
    ralsei.image_index  = 0;
    ralsei.image_speed  = 1;
    ralsei.anim_loop    = true;    // this object does the looping (below), so obj_ralsei doesn't freeze him on the last frame
    play(cast_sound);
}

// he holds the summon up (the sparkles loop) until the Knight smashes into him
if (r_phase == "stand" && instance_exists(ralsei) && ralsei.sprite_index == ralsei_cast_sprite
    && ralsei.image_index >= ralsei_hold_to + 1)
{
    ralsei.image_index = ralsei_hold_from + frac(ralsei.image_index);
}
if (_sec >= shield_at && once("shield"))
{
    shield_build();
    play(shield_sound);
}
if (_sec >= slam_at && once("slam"))
{
    beam_on = true;
    flash = flash_amt;
    shield.flash = 1;
    play(blast_sound, 1, blast_offset);
}
if (_sec >= slam_at + hum_delay && once("hum"))
{
    snd_hum = play(hum_sound, 0, 0, 1, true);
    if (snd_hum >= 0) audio_sound_gain(snd_hum, hum_gain, 500);
}

// the shield holding the beam back, shoved down onto them
if (shield.on)
{
    shield.t++;
    shield.grow  = min(1, shield.grow + 1 / (shield_grow * fps_));
    shield.flash = max(0, shield.flash - 0.08);
    var _giving  = (r_phase != "stand");
    shield.vis   = _giving ? random_range(1 - give_flicker, 1) : 1;

    if (beam_on)
    {
        shield.push = min(push_max, shield.push + push_speed / fps_);
        var _j = push_jitter * (_giving ? 2 : 1);
        shield.jx = random_range(-_j, _j);
        shield.jy = random_range(-_j, _j);

        // cracks: now and then while he holds it, fast once he's down
        crack_t++;
        if (!_giving)
        {
            if (crack_t >= crack_every * fps_) { crack_t = 0; shield_crack(); }
        }
        else if (give_n < give_crack_max && crack_t >= give_crack_every * fps_)
        {
            crack_t = 0;
            give_n++;
            shield_crack();
        }

        var _hit = beam_hit_shield(line_x(_sy), _sy);
        if (!is_undefined(_hit))
        {
            beam_ex = _hit.x;
            beam_ey = _hit.y;
            repeat (spark_rate)
                array_push(sparks, { x: beam_ex + random_range(-24, 24), y: beam_ey,
                                     vx: choose(-1, 1) * random_range(2, 6), vy: random_range(-4, -0.5),
                                     t: 0, life: irandom_range(12, 24) });
        }
    }
}

// ---------------------------------------------------------------- the Knight
if (instance_exists(scene) && instance_exists(scene.knight))
{
    var _k = scene.knight;

    if (_sec >= knight_down_at && once("knight_down"))
    {
        _k.visible = true;
        var _c = knight_center();
        knight_x0     = _c.x;
        knight_from_y = _c.y;
        knight_to_y   = party_feet_y + knight_level_dy;
        kstate = "down";
        kt = 0;
    }

    switch (kstate)
    {
        case "down":   // down to their level
        {
            kt++;
            var _e = clamp(kt / (knight_down_time * fps_), 0, 1);
            _e = _e * _e * (3 - 2 * _e);
            knight_place(knight_x0, lerp(knight_from_y, knight_to_y, _e));
            if (_e >= 1) { kstate = "wait"; kt = 0; }
        }
        break;

        case "wait":   // a beat, then his flying form, facing them
            if (++kt >= knight_transform_gap * fps_)
            {
                var _c = knight_center();
                _k.sprite_index = spr_knight_fly_transition;
                _k.image_index  = 0;
                _k.image_speed  = 1;
                _k.anim_loop    = false;
                _k.image_xscale = -abs(_k.image_xscale);   // they're to his left
                knight_place(_c.x, _c.y);
                play(transform_sound);
                kstate = "transform";
                kt = 0;
            }
        break;

        case "transform":
            if (_k.image_speed == 0 || _k.image_index >= _k.image_number - 1) { kstate = "pre_fly"; kt = 0; }
        break;

        case "pre_fly":
            if (++kt >= knight_fly_gap * fps_)
            {
                var _c = knight_center();
                _k.sprite_index = spr_knight_fly;
                _k.image_index  = 0;
                _k.image_speed  = 1;
                _k.anim_loop    = true;
                knight_place(_c.x, _c.y);
                scene.bob_amp = 0;   // no floating while he zooms
                play(zoom_sound);
                kstate = "fly";
                kt = 0;
            }
        break;

        case "fly":   // zooms left through them and off-screen
        {
            kt++;
            _k.x -= knight_fly_speed;
            if (kt mod knight_trail_every == 0)
            {
                var _sh = instance_create_layer(_k.x, _k.y, "Instances", obj_shadow);
                _sh.spr = _k.sprite_index;    _sh.frame = _k.image_index;
                _sh.xscale = _k.image_xscale; _sh.yscale = _k.image_yscale;
                _sh.angle = _k.image_angle;   _sh.alpha = 0.6;
                _sh.depth = _k.depth + 1;     _sh.drift_x = 0; _sh.drift_y = 0;
            }
            var _c = knight_center();

            // Susie flinches as he zips past her
            if (s_phase == "stand" && instance_exists(susie) && _c.x <= scr_get_feet(susie).x)
            {
                s_phase = "flinch";
                if (susie_flinch != noone) { susie.sprite_index = susie_flinch; susie.image_index = 0; susie.image_speed = 0; }
            }

            // ...and he smashes right into Ralsei
            if (r_phase == "stand" && instance_exists(ralsei) && _c.x <= scr_get_feet(ralsei).x + knight_hit_pad)
            {
                var _f = scr_get_feet(ralsei);
                r_fx = _f.x;
                r_fy = _f.y;
                r_phase = "knock";
                r_t = 0;
                ralsei.sprite_index = ralsei_fall_sprite;
                ralsei.image_index  = 0;
                ralsei.image_speed  = 0;
                ralsei.image_xscale = abs(ralsei.image_xscale) * ralsei_fall_face * ralsei_fall_native;
                for (var i = 0; i < array_length(hit_sounds); i++) play(hit_sounds[i]);
                shield.flash = 1;
                crack_t = 0;
                state = "giving";
                st = 0;
            }

            if (_c.x < _vx - 150) { _k.visible = false; kstate = "gone"; }
        }
        break;
    }
}

// ---------------------------------------------------------------- Ralsei knocked over
if (instance_exists(ralsei))
{
    if (r_phase == "knock")
    {
        r_t++;
        var _e = clamp(r_t / (knock_time * fps_), 0, 1);
        var _ease = 1 - (1 - _e) * (1 - _e);
        set_feet(ralsei, r_fx - knock_dist * _ease, r_fy - sin(_e * pi) * knock_hop);
        if (_e >= 1) r_phase = "down";
    }
    else if (r_phase == "down" && state != "done") set_feet(ralsei, r_fx - knock_dist, r_fy);
}

// ---------------------------------------------------------------- Susie jumping clear
if (instance_exists(susie))
{
    if (s_phase == "jump")
    {
        s_t++;
        var _e = clamp(s_t / (jump_time * fps_), 0, 1);
        set_feet(susie, s_fx + s_jdir * susie_jump * _e, s_fy - sin(_e * pi) * jump_h);
        if (_e >= 1)
        {
            susie.sprite_index = susie_land;
            susie.image_index  = 0;
            susie.image_speed  = 0;
            susie.image_xscale = abs(susie.image_xscale) * (-s_jdir) * susie_land_native;   // facing the beam
            s_phase = "landed";
        }
    }
    else if (s_phase == "landed" && state != "done") set_feet(susie, s_fx + s_jdir * susie_jump, s_fy);
}

// ---------------------------------------------------------------- "Watch out!", the break
switch (state)
{
    case "giving":   // he's down, it's giving way
        if (++st >= watchout_delay * fps_)
        {
            create_textbox(watchout_text);
            state = "talk";
        }
    break;

    case "talk":
        if (!instance_exists(obj_textbox))
        {
            // it breaks: Susie jumps clear and the beam hits where they were
            shield_shatter();
            beam_ey = _vy + _vh + 40;
            beam_ex = line_x(beam_ey);
            flash = flash_amt;
            play(break_sound);
            play(blast_sound, 1, blast_offset);
            if (instance_exists(susie))
            {
                var _f = scr_get_feet(susie);
                s_fx = _f.x;
                s_fy = _f.y;
                s_jdir = (_f.x < line_x(_f.y)) ? -1 : 1;   // away from the beam where it hits her level
                susie.sprite_index = susie_air;
                susie.image_index  = 0;
                susie.image_speed  = 0;
                s_phase = "jump";
                s_t = 0;
            }
            state = "beam_out";
            st = 0;
        }
    break;

    case "beam_out":
    {
        st++;
        var _a = beam_after * fps_;
        if (st > _a) beam_w = max(0, 1 - (st - _a) / (beam_thin * fps_));
        if (st >= _a && once("hum_out") && snd_hum >= 0) audio_sound_gain(snd_hum, 0, (beam_thin + 0.3) * 1000);
        if (beam_w <= 0) { beam_on = false; state = "done"; }
    }
    break;

    case "done":
        // Z opens the next self_ dialogue (self_4)
        if (once("unlock"))
        {
            global.cutscene_lock = false;
            global.dialogue_self = 3;
        }
    break;
}

// ---------------------------------------------------------------- bits
for (var i = array_length(shards) - 1; i >= 0; i--)
{
    var _p = shards[i];
    _p.t++;
    _p.vy += 0.25;
    _p.x += _p.vx;
    _p.y += _p.vy;
    _p.rot += _p.vr;
    if (_p.t >= 45) array_delete(shards, i, 1);
}
for (var i = array_length(sparks) - 1; i >= 0; i--)
{
    var _p = sparks[i];
    _p.t++;
    _p.vy += 0.2;
    _p.x += _p.vx;
    _p.y += _p.vy;
    if (_p.t >= _p.life) array_delete(sparks, i, 1);
}