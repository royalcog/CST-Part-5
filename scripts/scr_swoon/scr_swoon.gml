/// Full-screen swoon overlay + the layered slowed-down knight cut sounds
function scr_swoon(_sprite, _duration = 180, _on_finish = undefined, _gain = 5)
{
    var _s = instance_create_depth(0, 0, -10001, obj_swoon);
    _s.sprite_index = _sprite;
    _s.duration     = _duration;
    _s.on_finish    = _on_finish;
    _s.sound_gain   = _gain;

    var _pitches = [0.06, 0.1, 0.12, 0.18, 0.24];
    for (var i = 0; i < array_length(_pitches); i++)
    {
        var _snd = audio_play_sound(snd_knight_cut, 10, false);
        audio_sound_gain(_snd, _gain, 0);
        audio_sound_pitch(_snd, _pitches[i]);
        array_push(_s.sounds, _snd);
    }
    return _s;
}

/// bottom-center of an instance's current sprite, in room coords
function scr_get_feet(_obj)
{
    with (_obj)
    {
        return {
            x: x + (sprite_get_width(sprite_index) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale,
            y: y + (sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index)) * image_yscale
        };
    }
}

/// bottom-center of the *visible pixels* (bbox) — where the body actually is,
/// even in sprites with lots of empty canvas (like Ralsei's defeat/fall ones)
function scr_get_body(_obj)
{
    with (_obj)
    {
        return {
            x: x + ((sprite_get_bbox_left(sprite_index) + sprite_get_bbox_right(sprite_index) + 1) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale,
            y: y + (sprite_get_bbox_bottom(sprite_index) + 1 - sprite_get_yoffset(sprite_index)) * image_yscale
        };
    }
}

/// x/y an instance needs so _sprite's bottom-center lands on (_fx, _fy)
function scr_feet_to_xy(_obj, _sprite, _fx, _fy)
{
    return {
        x: _fx - (sprite_get_width(_sprite) / 2 - sprite_get_xoffset(_sprite)) * _obj.image_xscale,
        y: _fy - (sprite_get_height(_sprite) - sprite_get_yoffset(_sprite)) * _obj.image_yscale
    };
}

/// swap sprite without the character visually jumping (origins differ between sprites)
function scr_set_sprite_keep_feet(_obj, _sprite)
{
    if (!instance_exists(_obj)) exit;
    var _f = scr_get_feet(_obj);
    var _p = scr_feet_to_xy(_obj, _sprite, _f.x, _f.y);
    _obj.sprite_index = _sprite;
    _obj.image_index  = 0;
    _obj.image_speed  = 0;
    _obj.x = _p.x;
    _obj.y = _p.y;
    _obj.last_sprite = _sprite; // already re-anchored, so End Step doesn't do it again
}

/// same idea as scr_set_sprite_keep_feet, but lines up the bottom-center of the
/// *visible pixels* (bbox) instead of the whole canvas — for sprites like Ralsei's
/// battle ones whose canvas is a lot wider/taller than his body
function scr_set_sprite_keep_body(_obj, _sprite, _anim_loop = false)
{
    if (!instance_exists(_obj)) exit;
    with (_obj)
    {
        var _old = sprite_index;
        var _fx = x + ((sprite_get_bbox_left(_old) + sprite_get_bbox_right(_old) + 1) / 2 - sprite_get_xoffset(_old)) * image_xscale;
        var _fy = y + (sprite_get_bbox_bottom(_old) + 1 - sprite_get_yoffset(_old)) * image_yscale;
        x = _fx - ((sprite_get_bbox_left(_sprite) + sprite_get_bbox_right(_sprite) + 1) / 2 - sprite_get_xoffset(_sprite)) * image_xscale;
        y = _fy - (sprite_get_bbox_bottom(_sprite) + 1 - sprite_get_yoffset(_sprite)) * image_yscale;

        sprite_index = _sprite;
        last_sprite  = _sprite; // already placed, End Step shouldn't nudge it again
        image_index  = 0;
        image_speed  = _anim_loop ? 1 : 0;
        anim_loop    = _anim_loop;
    }
}

/// after Susie's swoon: fell sprite, knocked back to where she jumped from, screen shake
function scr_susie_knockback()
{
    if (!instance_exists(obj_susie)) exit;

    var _dur = 18;
    scr_set_sprite_keep_feet(obj_susie, spr_susie_fell);
    scr_swoon_fall_sounds();

    var _t  = scr_feet_to_xy(obj_susie, spr_susie_fell, obj_susie.leap_home_x, obj_susie.leap_home_y);
    var _dx = (_t.x - obj_susie.x) / _dur;
    var _dy = (_t.y - obj_susie.y) / _dur;
    scr_char_move_now(obj_susie, spr_susie_fell, false, _dx, _dy, 1, _dur, false, 0.05, "out");

    scr_camera_shake(4, 20);

    scr_call_after_frames(function() { global.cutscene_lock = false; }, _dur);
}

/// the hit/fall sound stack when a character drops into their fell/defeat sprite
/// _scale: multiplier on every layer's volume (1 = the original screenshot values)
/// returns the playing sound instances, so the crash can be cut off later (scr_stop_sounds)
function scr_swoon_fall_sounds(_scale = 0.75)
{
    var _layers = [
        [snd_impact,        1,   1],
        [snd_closet_impact, 1,   1],
        [snd_closet_impact, 1,   0.5],
        [snd_bageldefeat,   0.8, 0.8],
        [snd_damagetaken,   1,   1],
        [snd_glassbreak,    0.8, 0.4],
        [snd_glassbreak,    0.6, 0.3]
    ];

    var _playing = [];
    for (var i = 0; i < array_length(_layers); i++)
    {
        var _snd = audio_play_sound(_layers[i][0], 10, false);
        audio_sound_gain(_snd, _layers[i][1] * _scale, 0);
        audio_sound_pitch(_snd, _layers[i][2]);
        array_push(_playing, _snd);
    }
    return _playing;
}

/// stops every sound instance in an array (e.g. what scr_swoon_fall_sounds returned)
function scr_stop_sounds(_sounds)
{
    if (!is_array(_sounds)) exit;
    for (var i = 0; i < array_length(_sounds); i++)
    {
        audio_stop_sound(_sounds[i]);
    }
}

// ===================== SUSIE HEALS RALSEI / RUNNING OFF =====================

/// walks _obj so its feet land on (_fx, _fy): horizontal leg first, then vertical.
/// _px = pixels per frame. calls _on_done once it's standing exactly on the spot.
function scr_walk_feet_to(_obj, _spr_left, _spr_right, _spr_up, _spr_down, _fx, _fy, _px, _on_done = undefined)
{
    if (!instance_exists(_obj)) { if (_on_done != undefined) _on_done(); exit; }

    var _f  = scr_get_feet(_obj);
    var _dx = _fx - _f.x;
    var _dy = _fy - _f.y;
    var _hdur = (abs(_dx) >= 1) ? ceil(abs(_dx) / _px) : 0;
    var _vdur = (abs(_dy) >= 1) ? ceil(abs(_dy) / _px) : 0;

    var _ctx = {
        obj: _obj, fx: _fx, fy: _fy, done: _on_done,
        vspr: (_dy < 0) ? _spr_up : _spr_down, vstep: (_vdur > 0) ? _dy / _vdur : 0, vdur: _vdur
    };

    // vertical leg, then snap onto the exact spot
    var _second = method(_ctx, function()
    {
        if (vdur > 0) scr_char_move_now(obj, vspr, true, 0, vstep, 1, vdur);
        scr_call_after_frames(method(self, function()
        {
            if (instance_exists(obj))
            {
                var _p = scr_feet_to_xy(obj, obj.sprite_index, fx, fy);
                obj.x = _p.x;
                obj.y = _p.y;
                obj.image_index = 0;
                obj.image_speed = 0;
                obj.anim_loop = false;
            }
            if (done != undefined) done();
        }), vdur + 2);
    });

    if (_hdur > 0)
    {
        scr_char_move_now(_obj, (_dx < 0) ? _spr_left : _spr_right, true, _dx / _hdur, 0, 1, _hdur);
        scr_call_after_frames(_second, _hdur + 1);
    }
    else
    {
        _second();
    }
}

/// Susie's heal on downed Ralsei (same beats as self_15): charge fades in, heal lands on
/// frame 14 -> snd_heal + green flash -> Ralsei gets up shocked, Susie heal_end -> left_neutral.
/// global.susie_heal_busy is true the whole time; global.susie_heal_then (if set) runs when it's done.
function scr_susie_heal_ralsei(_on_done = undefined)
{
    global.susie_heal_busy = true;
    global.susie_heal_then = _on_done;

    with (obj_susie)
    {
        sprite_index = spr_susie_heal;
        image_index = 0;
        image_speed = 1;
        anim_loop = false; // freezes on her last frame
        charge_snd = scr_audio_fade_in(snd_charge, 1000, 1, true);
    }

    scr_call_on_anim_frame(obj_susie, spr_susie_heal, 14, function()
    {
        audio_play_sound(snd_heal, 1, false);

        var _f = instance_create_depth(0, 0, obj_ralsei.depth - 1, obj_heal_flash);
        _f.target = obj_ralsei;
        _f.duration = 60;
        _f.on_finish = function()
        {
            // Ralsei gets up right where his body is lying (spr_ralsei_fall_wince -> shocked)
            scr_set_sprite_keep_body(obj_ralsei, spr_ralsei_shocked);

            with (obj_susie)
            {
                sprite_index = spr_susie_heal_end;
                image_index = 0;
                image_speed = 1;
                anim_loop = false;
                audio_sound_gain(charge_snd, 0, 400);
            }
            scr_call_after_frames(function() { audio_stop_sound(obj_susie.charge_snd); }, 24);

            scr_call_after_frames(function()
            {
                with (obj_susie)
                {
                    sprite_index = spr_susie_left_neutral;
                    image_index = 0;
                    image_speed = 0;
                    anim_loop = true;
                }
                global.susie_heal_busy = false;
                var _cb = global.susie_heal_then;
                global.susie_heal_then = undefined;
                if (_cb != undefined) _cb();
            }, 40);
        };
    });
}

/// everyone listed runs left until fully offscreen, together. _runners = [ { obj, sprite }, ... ]
/// _px = pixels per frame. _on_done runs once the last one is gone.
function scr_run_off_left(_runners, _px, _on_done = undefined)
{
    var _cam_x = camera_get_view_x(view_camera[0]);
    var _longest = 0;

    for (var i = 0; i < array_length(_runners); i++)
    {
        var _r = _runners[i];
        if (!instance_exists(_r.obj)) continue;

        // where the run sprite's right edge will be once it's swapped in (feet stay put)
        var _f  = scr_get_feet(_r.obj);
        var _p  = scr_feet_to_xy(_r.obj, _r.sprite, _f.x, _f.y);
        var _xs = _r.obj.image_xscale;
        var _right = _p.x + (sprite_get_bbox_right(_r.sprite) + 1 - sprite_get_xoffset(_r.sprite)) * _xs;

        var _dur = ceil((_right - _cam_x + 8) / _px);
        _longest = max(_longest, _dur);
        scr_char_move_now(_r.obj, _r.sprite, true, -_px, 0, 1, _dur);
    }

    if (_on_done != undefined) scr_call_after_frames(_on_done, _longest + 2);
}

/// swap into a battle sprite without the body jumping.
/// _ref = sprite whose visible body to line up with (use the battle idle).
/// pass noone for _ref to swap in place (intro -> idle share the same body spot).
function scr_set_battle_sprite(_obj, _sprite, _ref, _loop)
{
    if (!instance_exists(_obj)) exit;
    with (_obj)
    {
        if (_ref != noone)
        {
            var _old = sprite_index;
            var _fx = x + ((sprite_get_bbox_left(_old) + sprite_get_bbox_right(_old) + 1) / 2 - sprite_get_xoffset(_old)) * image_xscale;
            var _fy = y + (sprite_get_bbox_bottom(_old) + 1 - sprite_get_yoffset(_old)) * image_yscale;
            x = _fx - ((sprite_get_bbox_left(_ref) + sprite_get_bbox_right(_ref) + 1) / 2 - sprite_get_xoffset(_ref)) * image_xscale;
            y = _fy - (sprite_get_bbox_bottom(_ref) + 1 - sprite_get_yoffset(_ref)) * image_yscale;
        }
        sprite_index = _sprite;
        last_sprite  = _sprite; // already placed, stop scr_auto_keep_feet from re-anchoring
        image_index  = 0;
        image_speed  = 1;
        anim_loop    = _loop;
    }
}