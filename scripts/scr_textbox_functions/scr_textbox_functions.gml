function scr_set_defaults_for_text()
{
	line_break_pos[0, global.page_number] = 999;
	line_break_num[global.page_number] = 0;
	line_break_offset[global.page_number] = 0;
	freeze_anim_on_finish[global.page_number] = false;
	
		//variables for every letter/character
	for (var c = 0; c < 500; c++)
	{
		col_1[c, global.page_number] = c_white; 
		col_2[c, global.page_number] = c_white; 
		col_3[c, global.page_number] = c_white; 
		col_4[c, global.page_number] = c_white; 
		
		float_text[c, global.page_number] = 0;
		float_dir[c, global.page_number] = c * 20;
		
		shake_text[c, global.page_number] = 0;
		shake_dir[c, global.page_number] = irandom(360);
		shake_timer[c, global.page_number] = irandom(4);
	}
	txtb_spr[global.page_number] = spr_textbox;
	global.speaker_sprite[global.page_number] = noone;
	global.speaker_side[global.page_number] = 1;
	global.portrait_x_offset[global.page_number] = border;
	global.speaker_image[global.page_number] = 0;
	snd[global.page_number] = noone;
	facing_change[global.page_number] = noone;
	facing_spr[global.page_number] = noone;
	text_cutoff[global.page_number] = noone;
	text_cutoff_speed[global.page_number] = noone;
	text_cutoff_threshold[global.page_number] = noone;
	facing_spr[global.page_number] = noone;
	speaker_shake[global.page_number] = false;
	speaker_shake_speed[global.page_number] = 6;
	speaker_shake_intensity[global.page_number] = 3;
	speaker_shake[global.page_number] = false;
	speaker_shake_speed[global.page_number] = 6;
	speaker_shake_intensity[global.page_number] = 3;
	speaker_shake_obj[global.page_number] = obj_spamton;
	speaker_portrait_tail_spr[global.page_number] = noone;
	text_x_offset_right[global.page_number] = 0;
	text_speed_override[global.page_number] = noone;
	secondary_text[global.page_number] = "";
	secondary_portrait_spr[global.page_number] = noone;
	secondary_image[global.page_number] = 0;
	secondary_side[global.page_number] = 1;
	secondary_col[global.page_number] = c_white;
	secondary_snd[global.page_number] = noone;
	hide_face[global.page_number] = false;
	secondary_snd_delay[global.page_number] = 2;
}

/// @param text - the aside/mini-textbox line (no border, drawn under the main box)
/// @param [character] - same character id used by scr_text ("susie", "ralsei", etc.) — sets color, sound, and default portrait
/// @param [image] - which frame/index of the character's portrait sprite to draw (e.g. a specific expression)
/// @param [side] - 1 or -1, mirrors the portrait horizontally (same convention as global.speaker_side)
function scr_text_secondary(_text, _character = noone, _image = 0, _side = 1)
{
	var _page = global.page_number - 1;
	secondary_text[_page] = _text;
	secondary_image[_page] = _image;
	secondary_side[_page] = _side;
	secondary_col[_page] = c_white;
	secondary_portrait_spr[_page] = noone;
	secondary_snd[_page] = noone;

	if (_character != noone)
	{
		switch (_character)
		{
			case "susie":
				secondary_col[_page] = make_colour_rgb(175, 103, 175);
				secondary_portrait_spr[_page] = spr_susie_dialogue;
				secondary_snd[_page] = snd_susie;
				secondary_snd_delay[_page] = .7;
			break;

			case "ralsei":
				secondary_col[_page] = make_colour_rgb(77, 204, 142);
				secondary_portrait_spr[_page] = spr_ralsei_dialogue;
				secondary_snd[_page] = snd_ralsei;
				secondary_snd_delay[_page] = .7;
			break;

			case "noelle":
				secondary_col[_page] = make_colour_rgb(255, 253, 250);
				secondary_portrait_spr[_page] = spr_noelle_dialogue;
				secondary_snd[_page] = snd_noelle;
			break;

			case "lancer":
				secondary_col[_page] = make_colour_rgb(85, 133, 189);
				secondary_portrait_spr[_page] = spr_lancer_dialogue;
				secondary_snd[_page] = snd_lancer;
			break;

			case "mewmew":
				secondary_col[_page] = make_colour_rgb(255, 138, 144);
				secondary_snd[_page] = snd_empty;
			break;

			case "gerson":
				secondary_col[_page] = make_colour_rgb(101, 170, 38);
				secondary_snd[_page] = snd_gerson;
			break;
			
			case "queen":
			    secondary_col[_page] = make_colour_rgb(111, 209, 255);
			    secondary_portrait_spr[_page] = spr_queen_dialogue;
			    secondary_snd[_page] = snd_queen;
			    secondary_snd_delay[_page] = .7;
			break;
		}
	}
}

//text VFX
/// @param 1st_char
/// @param last_char
/// @param col1
/// @param col2
/// @param col3
/// @param col4
function scr_text_color(_start, _end, _col1, _col2, _col3, _col4)
{
	for (var c = _start; c <= _end; c++)
	{
		col_1[c, global.page_number - 1] = _col1;
		col_2[c, global.page_number - 1] = _col2;
		col_3[c, global.page_number - 1] = _col3;
		col_4[c, global.page_number - 1] = _col4;
	}
}

function scr_text_color_default(_col)
{
    for (var c = 0; c < 500; c++)
    {
        col_1[c, global.page_number] = _col;
        col_2[c, global.page_number] = _col;
        col_3[c, global.page_number] = _col;
        col_4[c, global.page_number] = _col;
    }
}

function scr_text_color_gradient(_col_top, _col_bottom)
{
    for (var c = 0; c < 500; c++)
    {
        col_1[c, global.page_number] = _col_top;
        col_2[c, global.page_number] = _col_top;
        col_3[c, global.page_number] = _col_bottom;
        col_4[c, global.page_number] = _col_bottom;
    }
}

/// @param 1st_char
/// @param last_char
function scr_text_float(_start, _end)
{
	for (var c = _start; c <= _end; c++)
	{
		float_text[c, global.page_number - 1] = true;
	}
}

/// @param 1st_char
/// @param last_char
function scr_text_shake(_start, _end)
{
	for (var c = _start; c <= _end; c++)
	{
		shake_text[c, global.page_number - 1] = true;
	}
}

function scr_text_face(_dir)
{
	facing_change[global.page_number - 1] = _dir;
}

function scr_text_face_spr(_dir, _spr)
{
    facing_change[global.page_number - 1] = _dir;
    facing_spr[global.page_number - 1] = _spr;
}

function scr_obj_spawn_on_page(_obj, _x, _y, _layer)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    
    var _entry = {
        obj: _obj,
        x: _x,
        y: _y,
        layer: _layer,
        page: global.page_number - 1,
        type: "spawn"
    };
    
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, _entry);
}

function scr_obj_sprite_on_page(_obj, _sprite, _loop)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;

    var _ch = obj_cutscenehandler_midfightattacks;

    var _entry = {
	    obj: _obj,
	    sprite: _sprite,
	    loop: _loop,
	    image: argument_count > 3 ? argument[3] : 0,
	    page: global.page_number - 1,
	    type: "sprite",
	    snd: noone,
	    snd_gain: 1
	};

    array_push(_ch.sprite_queue, _entry);
}

function scr_obj_sprite_on_page_delayed(_obj, _sprite, _loop, _image, _delay)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue_delayed, {
        obj: _obj,
        sprite: _sprite,
        loop: _loop,
        image: _image,
        delay: _delay,
        page: global.page_number - 1,
        snd: noone,
        snd_gain: 1
    });
}

/// @param _obj - instance to set the variable on, or noone to set a global variable instead
/// @param _var_name - variable name as a string (e.g. "sprite_index", "my_flag")
/// @param _value - value to set it to
/// @param _delay - frames to wait; only counts down while the page it was called on is still showing
function scr_set_var_on_page_delayed(_obj, _var_name, _value, _delay)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue_delayed, {
        page: global.page_number - 1,
        delay: _delay,
        is_custom_call: true,
        call_func: method({ obj: _obj, var_name: _var_name, value: _value }, function()
        {
            if (obj == noone)
            {
                variable_global_set(var_name, value);
            }
            else if (instance_exists(obj))
            {
                variable_instance_set(obj, var_name, value);
            }
        })
    });
}

function scr_obj_spawn_after_textbox(_obj, _x, _y, _layer)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "spawn",
        obj: _obj,
        x: _x,
        y: _y,
        layer: _layer,
        snd: argument_count > 4 ? argument[4] : noone,
        snd_gain: argument_count > 5 ? argument[5] : 1
    });
}

function scr_obj_sprite_after_textbox(_obj, _sprite, _loop)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "sprite",
        obj: _obj,
        sprite: _sprite,
        loop: _loop,
        image: argument_count > 3 ? argument[3] : 0, // add this
        snd: argument_count > 4 ? argument[4] : noone,
        snd_gain: argument_count > 5 ? argument[5] : 1
    });
}

function scr_obj_sprite_after_textbox_delayed(_obj, _sprite, _loop, _delay)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.pending_delayed_queue, {
        obj: _obj,
        sprite: _sprite,
        loop: _loop,
        delay: _delay,
        snd: argument_count > 4 ? argument[4] : noone,
        snd_gain: argument_count > 5 ? argument[5] : 1
    });
}

function scr_text_cutoff(_char)
{
    text_cutoff[global.page_number - 1] = _char;
}

function scr_text_cutoff_skip(_char)
{
    text_cutoff[global.page_number - 1] = _char;
    cutoff_skip[global.page_number - 1] = true;
}

function scr_text_cutoff_slow(_char, _threshold, _speed)
{
    obj_textbox.text_cutoff[global.page_number - 1] = _char;
    obj_textbox.text_cutoff_speed[global.page_number - 1] = _speed;
    obj_textbox.text_cutoff_threshold[global.page_number - 1] = _threshold;
}

function scr_text_speaker_shake(_speed, _intensity, _obj = obj_spamton)
{
    obj_textbox.speaker_shake[global.page_number - 1] = true;
    obj_textbox.speaker_shake_speed[global.page_number - 1] = _speed;
    obj_textbox.speaker_shake_intensity[global.page_number - 1] = _intensity;
    obj_textbox.speaker_shake_obj[global.page_number - 1] = _obj;
}

function scr_text_speaker_shake_stop()
{
    obj_textbox.speaker_shake[global.page_number - 1] = false;
    with (obj_textbox)
    {
        if (variable_instance_exists(id, "shaking_obj") && instance_exists(shaking_obj))
        {
            scr_char_shake_stop(shaking_obj);
        }
        shaking_obj = noone;
    }
}

function scr_char_shake_update(_obj, _speed, _intensity)
{
    if (!variable_instance_exists(_obj, "shake_active") || !_obj.shake_active)
    {
        // (re)capture the resting position every time a new shake starts
        _obj.shake_active  = true;
        _obj.shake_offset  = 0;
        _obj.shake_dir_osc = 1;
        _obj.shake_base_x  = _obj.x;
    }
    _obj.shake_offset += _speed * _obj.shake_dir_osc;
    if _obj.shake_offset >= _intensity
    {
        _obj.shake_offset = _intensity;
        _obj.shake_dir_osc = -1;
    }
    else if _obj.shake_offset <= -_intensity
    {
        _obj.shake_offset = -_intensity;
        _obj.shake_dir_osc = 1;
    }
    _obj.x = _obj.shake_base_x + _obj.shake_offset;
}

function scr_char_shake_stop(_obj)
{
    if (variable_instance_exists(_obj, "shake_active") && _obj.shake_active)
    {
        _obj.x = _obj.shake_base_x;
        _obj.shake_offset = 0;
        _obj.shake_active = false;
    }
}

function scr_tenna_shake_after_textbox(_state)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "tenna_shake",
        state: _state
    });
}

function scr_snd_on_textbox(_snd, _gain)
{
    var _g = argument_count > 1 ? _gain : 1;
    audio_play_sound(_snd, 1, false, _g);
}

function scr_snd_after_textbox(_snd, _gain)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "sound",
        snd: _snd,
        snd_gain: argument_count > 1 ? _gain : 1
    });
}

function scr_snd_on_page(_snd, _gain)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, {
        type: "sound",
        page: global.page_number - 1,
        snd: _snd,
        snd_gain: argument_count > 1 ? _gain : 1
    });
}

function scr_snd_after_textbox_delayed(_snd, _gain, _frames)
{
    var _inst = instance_create_depth(0, 0, 0, obj_delayed_caller);
    _inst.call_func = method({ snd: _snd, gain: _gain }, function()
    {
        audio_play_sound(snd, 1, false, gain);
    });
    _inst.frames_left = _frames;
    _inst.mode = "after_textbox";
    return _inst;
}

function scr_fist_split_after_textbox(_edge_margin, _lerp_speed, _fade_speed)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "fist_split",
        edge_margin: argument_count > 0 ? _edge_margin : 40,
        lerp_speed: argument_count > 1 ? _lerp_speed : 0.08,
        fade_speed: argument_count > 2 ? _fade_speed : 0.04
    });
}

function scr_sparkle_heroes_after_textbox(_heroes)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "sparkle_heroes",
        heroes: _heroes
    });
}

function scr_portrait_on_page(_spr)
{
    speaker_portrait_spr[global.page_number - 1] = _spr;
}

function scr_portrait_tail_off()
{
    speaker_portrait_tail_spr[global.page_number - 1] = noone;
}

function scr_blackbox_spawn_after_textbox(_obj, _x, _y, _layer, _state)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "blackbox",
        obj: _obj,
        x: _x,
        y: _y,
        layer: _layer,
		state: _state,
        snd: argument_count > 5 ? argument[5] : noone,
        snd_gain: argument_count > 6 ? argument[6] : 1
    });
}

function scr_blackbox_delete_on_page()
{
    if instance_exists(obj_cutscenehandler_midfightattacks) 
    && variable_instance_exists(obj_cutscenehandler_midfightattacks, "blackbox_instance")
    && instance_exists(obj_cutscenehandler_midfightattacks.blackbox_instance)
    {
        instance_destroy(obj_cutscenehandler_midfightattacks.blackbox_instance);
        obj_cutscenehandler_midfightattacks.blackbox_instance = noone;
        
        if argument_count > 0 && argument[0] != noone
        {
            var _gain = argument_count > 1 ? argument[1] : 1;
            obj_cutscenehandler_midfightattacks.blackbox_sound_asset = argument[0]; // store it here
            obj_cutscenehandler_midfightattacks.blackbox_sound = audio_play_sound(argument[0], 10, false, _gain);
        }
    }
}

function scr_roark_ball_start()
{
    if instance_exists(obj_knight)
    {
        obj_knight.sprite_index = spr_roark_ball;
        obj_knight.image_speed = 1;
        obj_knight.image_index = 0;
        obj_knight.anim_loop = true;
        obj_knight.ball_phase = 1;
    }
}

/// spawn the Knight offscreen left (if needed) and fly him in as the ball to _target_x
function scr_knight_fly_in(_target_x, _y, _start_x = -220, _speed = 5)
{
    var _k = instance_exists(obj_knight) ? obj_knight : instance_create_depth(_start_x, _y, -1003, obj_knight);
    _k.x = _start_x;
    _k.y = _y;
    _k.ball_target_x = _target_x;
    _k.ball_speed    = _speed;
    scr_roark_ball_start();
}

function scr_knight_ball_after_textbox()
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "knight_ball"
    });
}

function scr_knight_to_ball()
{
    if instance_exists(obj_knight)
    {
        // swap the sprite FIRST: image_number has to be the ball sprite's, not whatever he was in before
        // (his sword sprite has 19 frames vs the ball's 9, which made him play the ball turn twice)
        obj_knight.sprite_index = spr_roark_ball_to_knight;
        obj_knight.image_speed = 0;
        obj_knight.image_index = obj_knight.image_number - 1;
        obj_knight.reverse_frame = obj_knight.image_number - 1;
        obj_knight.reverse_phase = 1;
    }
}

function scr_knight_to_ball_after_textbox()
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "knight_to_ball"
    });
}

function scr_impact_sequence_after_textbox()
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "impact_sequence"
    });
}

function scr_text_slow(_speed)
{
    text_speed_override[global.page_number - 1] = _speed;
}

function scr_villains_ascend_after_textbox()
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "villains_ascend"
    });
}

function scr_villains_descend_after_textbox()
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "villains_descend"
    });
}


// BG Movement
function scr_call_trigger_shadow_pause(_target_object, _sprite, _wait_seconds)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "CTSP",
        target_object: _target_object,
        sprite: _sprite,
        wait_seconds: _wait_seconds
    });
}

function scr_call_trigger_pause_only(_target_object, _wait_seconds)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "PAUSE_ONLY",
        target_object: _target_object,
        wait_seconds: _wait_seconds
    });
}

function scr_call_trigger_resume_scrolling(_target_object)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "RESUME_SCROLL",
        target_object: _target_object
    });
}

function scr_call_trigger_fade_special_sprite(_target_object, _new_sprite, _new_image, _fade_speed)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "FADE_SPECIAL",
        target_object: _target_object,
        sprite: _new_sprite,
        image: _new_image,
        fade_speed: _fade_speed
    });
}

function trigger_object_fade(_target_object, _new_sprite, _new_image, _new_x, _new_y, _fade_speed)
{
    with (_target_object)
    {
        fade_active = true;
        fade_old_sprite = sprite_index;
        fade_old_image = image_index;
        fade_new_sprite = _new_sprite;
        fade_new_image = _new_image;
        fade_x = _new_x;
        fade_y = _new_y;
        fade_alpha = 0;
        fade_speed = _fade_speed;
		spawnedin = true;
    }
}

function scr_call_trigger_object_fade(_target_object, _new_sprite, _new_image, _new_x, _new_y, _fade_speed)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "OBJECT_FADE",
        target_object: _target_object,
        sprite: _new_sprite,
        image: _new_image,
        target_x: _new_x,
        target_y: _new_y,
        fade_speed: _fade_speed
    });
}

function scr_call_trigger_object_fade_on_page(_target_object, _new_sprite, _new_image, _new_x, _new_y, _fade_speed)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, {
        type: "object_fade",
        target_object: _target_object,
        sprite: _new_sprite,
        image: _new_image,
        target_x: _new_x,
        target_y: _new_y,
        fade_speed: _fade_speed,
        page: global.page_number - 1
    });
}

function scr_fade_special_sprite_on_page(_target_object, _new_sprite, _new_image, _fade_speed)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, {
        type: "fade_special",
        target_object: _target_object,
        sprite: _new_sprite,
        image: _new_image,
        fade_speed: _fade_speed,
        page: global.page_number - 1
    });
}



/// @function scr_fade_out_to_black()
/// @description Enqueues a fade out to black that waits for previous movements to finish.
// Inside your scr_fade_out_to_black script definition:
function scr_fade_out_to_black(_color = c_black, _same_room = false, _wait = 0) {
    if (!instance_exists(obj_cutscenefade))
    {
        var _fader = instance_create_depth(0, 0, -9999, obj_cutscenefade);
        _fader.fade_target = 1;
        _fader.target_room = room; 
        _fader.fade_color = _color;
        _fader.fade_back_same_room = _same_room;
        _fader.flash_wait_duration = _wait;
        _fader.hold_black = true;
    }
}

function scr_fade_after_textbox(_color = c_black, _same_room = false, _wait = 0, _hold_black = false) {
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    
    array_push(obj_cutscenehandler_midfightattacks.pending_delayed_queue, {
        type: "fade",
        is_fade: true,
        fade_color: _color,
        fade_back_same_room: _same_room,
        wait_duration: _wait,
        hold_black: _hold_black,
        movement_duration: 0,
        delay: 0
    });
}

// This is your "Warp" function
function scr_instant_warp(_target_room) {
    if (!instance_exists(obj_cutscenefade)) {
        var _fader = instance_create_depth(0, 0, -9999, obj_cutscenefade);
        _fader.fade_target = 1;         // Fades to black
        _fader.target_room = _target_room; // Fader object handles the room switch
    }
}

function scr_char_move_on_page(_obj, _sprite, _loop, _dx, _dy, _speed, _duration, _ease = "none")
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, {
        type: "move_start",
        obj: _obj,
        sprite: _sprite,
        loop: _loop,
        dx: _dx,
        dy: _dy,
        speed: _speed,
        duration: _duration,
        ease: _ease,
        page: global.page_number - 1
    });
}

function scr_char_move_after_textbox(_obj, _sprite, _loop, _dx, _dy, _speed, _duration, _fade_out = false, _fade_speed = 0.05, _ease = "none") {
    
    var _cutscene_obj = obj_cutscenehandler_midfightattacks;
    
    if (instance_exists(_cutscene_obj))
    {
        var _calculated_delay = 0;
        for (var i = 0; i < array_length(_cutscene_obj.pending_delayed_queue); i++)
        {
            if (variable_struct_exists(_cutscene_obj.pending_delayed_queue[i], "movement_duration"))
            {
                _calculated_delay += _cutscene_obj.pending_delayed_queue[i].movement_duration;
            }
        }

        var _entry = {
            is_movement: true,
            obj: _obj,
            sprite: _sprite,
            loop: _loop,
            dx: _dx,
            dy: _dy,
            speed: _speed,
            movement_duration: _duration,
            delay: _calculated_delay,
            fade_out: _fade_out,        
            fade_speed: _fade_speed,
            ease: _ease
        };

        array_push(_cutscene_obj.pending_delayed_queue, _entry);
        _cutscene_obj.after_queue_armed = true;
    }
}

function scr_char_move_now(_obj, _sprite, _loop, _dx, _dy, _speed, _duration, _fade_out = false, _fade_speed = 0.05, _ease = "none")
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.move_queue_active, {
        obj: _obj,
        sprite: _sprite,
        loop: _loop,
        dx: _dx,
        dy: _dy,
        speed: _speed,
        duration: _duration,
        timer: 0,
        started: false,
        fade_out: _fade_out,
        fade_speed: _fade_speed,
        fading: false,
        ease: _ease
    });
}

function scr_teleport_after_textbox(_obj, _x, _y, _sprite = noone, _image_index = 0)
{
    var _cutscene_obj = obj_cutscenehandler_midfightattacks;
    if (!instance_exists(_cutscene_obj)) exit;

    var _calculated_delay = 0;
    for (var i = 0; i < array_length(_cutscene_obj.pending_delayed_queue); i++)
    {
        if (variable_struct_exists(_cutscene_obj.pending_delayed_queue[i], "movement_duration"))
        {
            _calculated_delay += _cutscene_obj.pending_delayed_queue[i].movement_duration;
        }
    }

    var _entry = {
        is_teleport: true,
        obj: _obj,
        x: _x,
        y: _y,
        sprite: _sprite,
        image_index: _image_index,
        movement_duration: 0, // takes no time, but still counts toward ordering
        delay: _calculated_delay
    };

    array_push(_cutscene_obj.pending_delayed_queue, _entry);
}

function scr_set_var_on_page(_obj, _var_name, _value)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, {
        type: "set_var_page",
        obj: _obj,
        var_name: _var_name,
        value: _value,
        page: global.page_number - 1
    });
}

function scr_set_var_after_textbox(_obj, _var_name, _value)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "set_var",
        obj: _obj,
        var_name: _var_name,
        value: _value
    });
}

function scr_fade_warp_with_music(_target_room, _wait_frames, _new_sound, _new_gain = 1, _fade_in_time = 1000, _fade_out_time = 500, _music_lead_frames = 0, _spawn_list = [], _fade_frames = 100)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "fade_warp_music",
        target_room: _target_room,
        wait_frames: _wait_frames,
        new_sound: _new_sound,
        new_gain: _new_gain,
        fade_in_time: _fade_in_time,
        fade_out_time: _fade_out_time,
        music_lead_frames: _music_lead_frames,
        spawn_list: _spawn_list,
        fade_frames: _fade_frames
    });
	global.warp_pending = true;
}

// Helper for building one spawn_list entry for scr_fade_warp_with_music.
// _setup (optional) is a method taking the new instance and applying sprite/flags/etc to it.
function scr_make_warp_spawn(_obj, _x, _y, _layer = "Instances", _setup = noone)
{
    return { obj: _obj, x: _x, y: _y, layer: _layer, setup: _setup };
}

function scr_orb_transform()
{
    obj_orb.is_fading = true;
}

function scr_orb_grow()
{
	obj_orb.scaleup = true;
}

function scr_orb_shrink()
{
	obj_orb.scaledown = true;
}

function scr_impact_flash_after_textbox(_target_obj, _silhouette_spr, _circle_speed, _knockback_speed, _knockback_friction, _next_text_id, _wait_frames = 90, _knockback_dir = 270, _circle_start_x = 705, _circle_start_y = 120, _gerson_obj = noone, _gerson_speed = 2, _gerson_dir = 200, _gerson_friction = 0.3, _hit_sprite = noone, _yelling_sprite = noone, _spawn_obj = noone, _original_sprite = noone)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "impact_flash",
        target_obj: _target_obj,
        silhouette_spr: _silhouette_spr,
        circle_speed: _circle_speed,
        hit_sprite: _hit_sprite,
        yelling_sprite: _yelling_sprite,
        knockback_speed: _knockback_speed,
        knockback_friction: _knockback_friction,
        next_text_id: _next_text_id,
        wait_frames: _wait_frames,
        knockback_dir: _knockback_dir,
        circle_start_x: _circle_start_x,
        circle_start_y: _circle_start_y,
        gerson_obj: _gerson_obj,
        gerson_speed: _gerson_speed,
        gerson_dir: _gerson_dir,
        gerson_friction: _gerson_friction,
        spawn_obj: _spawn_obj,
        original_sprite: _original_sprite
    });
}

function scr_damage_on_page(_obj, _amount, _color_top = noone, _color_bottom = noone)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;

    var _final_top = _color_top;
    if (_final_top == noone)
    {
        _final_top = variable_instance_exists(_obj, "damage_color_top") ? _obj.damage_color_top : c_white;
    }

    var _final_bottom = _color_bottom;
    if (_final_bottom == noone)
    {
        _final_bottom = variable_instance_exists(_obj, "damage_color_bottom") ? _obj.damage_color_bottom : _final_top;
    }

    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, {
        type: "damage_number",
        obj: _obj,
        amount: _amount,
        color_top: _final_top,
        color_bottom: _final_bottom,
        page: global.page_number - 1
    });
}

function scr_damage_after_textbox(_obj, _amount, _color_top = noone, _color_bottom = noone, _delay = 0)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;

    var _final_top = _color_top;
    if (_final_top == noone)
    {
        _final_top = variable_instance_exists(_obj, "damage_color_top") ? _obj.damage_color_top : c_white;
    }

    var _final_bottom = _color_bottom;
    if (_final_bottom == noone)
    {
        _final_bottom = variable_instance_exists(_obj, "damage_color_bottom") ? _obj.damage_color_bottom : _final_top;
    }

    if (_delay > 0)
    {
        array_push(obj_cutscenehandler_midfightattacks.pending_delayed_queue, {
            is_damage_number: true,
            obj: _obj,
            amount: _amount,
            color_top: _final_top,
            color_bottom: _final_bottom,
            delay: _delay
        });
    }
    else
    {
        array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
            type: "damage_number",
            obj: _obj,
            amount: _amount,
            color_top: _final_top,
            color_bottom: _final_bottom
        });
    }
}

function scr_custom_call_after_textbox_delayed(_func, _delay)
{
    if (!instance_exists(obj_cutscenehandler_midfightattacks)) exit;
    array_push(obj_cutscenehandler_midfightattacks.pending_delayed_queue, {
        is_custom_call: true,
        call_func: _func,
        delay: _delay
    });
}

/// @param _obj - instance to set the variable on, or noone to set a global variable instead
/// @param _var_name - variable name as a string (e.g. "sprite_index", "my_flag")
/// @param _value - value to set it to
/// @param _delay - frames to wait after the textbox closes
function scr_set_var_after_textbox_delayed(_obj, _var_name, _value, _delay)
{
    if (!instance_exists(obj_cutscenehandler_midfightattacks)) exit;
    scr_custom_call_after_textbox_delayed(method({ obj: _obj, var_name: _var_name, value: _value }, function()
    {
        if (obj == noone)
        {
            variable_global_set(var_name, value);
        }
        else if (instance_exists(obj))
        {
            variable_instance_set(obj, var_name, value);
        }
    }), _delay);
}

function scr_queue_movement_group_after_textbox(_moves)
{
    if (!instance_exists(obj_cutscenehandler_midfightattacks)) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "movement_group",
        moves: _moves
    });
}

function scr_ghost_on_page(_obj)
{
    if (!instance_exists(obj_cutscenehandler_midfightattacks)) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, {
        type: "ghost_sync",
        obj: _obj,
        page: global.page_number - 1
    });
}

function scr_spawn_fade_in(_obj, _x, _y, _layer, _fade_speed = 0.05)
{
    var _inst = instance_create_layer(_x, _y, _layer, _obj);
    _inst.image_alpha = 0;
    _inst.fade_in_speed = _fade_speed;
    _inst.fading_in = true;
    return _inst;
}

function scr_obj_spawn_fade_in_after_textbox(_obj, _x, _y, _layer, _fade_speed = 0.05)
{
    if (!instance_exists(obj_cutscenehandler_midfightattacks)) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "spawn_fade_in",
        obj: _obj,
        x: _x,
        y: _y,
        layer: _layer,
        fade_speed: _fade_speed
    });
}

/// @param layer_name - the room layer's name (string), e.g. "Instances_Foreground"
/// @param [hide] - true to hide the layer, false to show it (default true)
/// @param [snd] - optional sound to play the moment the layer toggles
/// @param [snd_gain] - gain for that sound (default 1)
/// Fires as soon as the given page is reached (no delay).
function scr_layer_hide_on_page(_layer_name, _hide = true, _snd = noone, _snd_gain = 1)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, {
        type: "layer_visible",
        layer_name: _layer_name,
        visible: !_hide,
        page: global.page_number - 1,
        snd: _snd,
        snd_gain: _snd_gain
    });
}

/// @param layer_name - the room layer's name (string)
/// @param hide - true to hide the layer, false to show it
/// @param delay - frames to wait (while the matching page is active) before toggling
/// @param [snd] - optional sound to play the moment the layer toggles
/// @param [snd_gain] - gain for that sound (default 1)
function scr_layer_hide_on_page_delayed(_layer_name, _hide, _delay, _snd = noone, _snd_gain = 1)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.sprite_queue_delayed, {
        type: "layer_visible",
        layer_name: _layer_name,
        visible: !_hide,
        delay: _delay,
        page: global.page_number - 1,
        snd: _snd,
        snd_gain: _snd_gain
    });
}

/// @param layer_name - the room layer's name (string)
/// @param [hide] - true to hide the layer, false to show it (default true)
/// @param [snd] - optional sound to play the moment the layer toggles
/// @param [snd_gain] - gain for that sound (default 1)
/// Fires as soon as the textbox fully closes (no delay).
function scr_layer_hide_after_textbox(_layer_name, _hide = true, _snd = noone, _snd_gain = 1)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;
    array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
        type: "layer_visible",
        layer_name: _layer_name,
        visible: !_hide,
        snd: _snd,
        snd_gain: _snd_gain
    });
}

/// @param layer_name - the room layer's name (string)
/// @param hide - true to hide the layer, false to show it
/// @param delay - frames to wait after the textbox closes before toggling (chains after any movement(s) already queued for this batch, same as scr_char_move_after_textbox)
/// @param [snd] - optional sound to play the moment the layer toggles
/// @param [snd_gain] - gain for that sound (default 1)
function scr_layer_hide_after_textbox_delayed(_layer_name, _hide, _delay, _snd = noone, _snd_gain = 1)
{
    var _cutscene_obj = obj_cutscenehandler_midfightattacks;
    if !instance_exists(_cutscene_obj) exit;

    var _calculated_delay = _delay;
    for (var i = 0; i < array_length(_cutscene_obj.pending_delayed_queue); i++)
    {
        if (variable_struct_exists(_cutscene_obj.pending_delayed_queue[i], "movement_duration"))
        {
            _calculated_delay += _cutscene_obj.pending_delayed_queue[i].movement_duration;
        }
    }

    array_push(_cutscene_obj.pending_delayed_queue, {
        is_layer_toggle: true,
        layer_name: _layer_name,
        visible: !_hide,
        delay: _calculated_delay,
        snd: _snd,
        snd_gain: _snd_gain
    });
}

/// @param layer_name - the room layer's name (string)
/// @param [snd] - optional sound to play the moment the layer reappears
/// @param [snd_gain] - gain for that sound (default 1)
/// Fires as soon as the given page is reached (no delay). Same as scr_layer_hide_on_page(_layer_name, false, ...).
function scr_layer_show_on_page(_layer_name, _snd = noone, _snd_gain = 1)
{
    scr_layer_hide_on_page(_layer_name, false, _snd, _snd_gain);
}

/// @param layer_name - the room layer's name (string)
/// @param delay - frames to wait (while the matching page is active) before reappearing
/// @param [snd] - optional sound to play the moment the layer reappears
/// @param [snd_gain] - gain for that sound (default 1)
function scr_layer_show_on_page_delayed(_layer_name, _delay, _snd = noone, _snd_gain = 1)
{
    scr_layer_hide_on_page_delayed(_layer_name, false, _delay, _snd, _snd_gain);
}

/// @param layer_name - the room layer's name (string)
/// @param [snd] - optional sound to play the moment the layer reappears
/// @param [snd_gain] - gain for that sound (default 1)
/// Fires as soon as the textbox fully closes (no delay). Same as scr_layer_hide_after_textbox(_layer_name, false, ...).
function scr_layer_show_after_textbox(_layer_name, _snd = noone, _snd_gain = 1)
{
    scr_layer_hide_after_textbox(_layer_name, false, _snd, _snd_gain);
}

/// @param layer_name - the room layer's name (string)
/// @param delay - frames to wait after the textbox closes before reappearing (chains after any movement(s) already queued for this batch)
/// @param [snd] - optional sound to play the moment the layer reappears
/// @param [snd_gain] - gain for that sound (default 1)
function scr_layer_show_after_textbox_delayed(_layer_name, _delay, _snd = noone, _snd_gain = 1)
{
    scr_layer_hide_after_textbox_delayed(_layer_name, false, _delay, _snd, _snd_gain);
}

function scr_text_hide_face(_bool)
{
    global.hide_face = _bool;
}

function scr_obj_sprite_once_on_page(_obj, _sprite, _start_image = 0)
{
    if !instance_exists(obj_cutscenehandler_midfightattacks) exit;

    array_push(obj_cutscenehandler_midfightattacks.sprite_queue, {
        obj: _obj,
        sprite: _sprite,
        image: _start_image,
        page: global.page_number - 1,
        type: "sprite_once",
        snd: noone,
        snd_gain: 1
    });
}

/// @param text
/// @param [character]
/// @param [index]
/// @param [silent]
/// @param [freeze]
/// @param [hide_face] - true hides the portrait for just this line, keeping the character's color/voice sound
function scr_text(_text, _character = noone, _index = noone, _mode = noone, _freeze = false, _hide_face = false)
{
	scr_set_defaults_for_text();
	text[global.page_number] = _text;
	snd_delay[global.page_number] = 2;
	speaker_portrait_spr[global.page_number] = noone;
	speaker_portrait_frame[global.page_number] = 0;
	speaker_portrait_animating[global.page_number] = false;
	cutoff_skip[global.page_number] = false;
	
	
	//get character info
	if argument_count > 1
	{
		switch(argument[1])
		{
			case "susie":
				scr_text_color_default(make_colour_rgb(175, 103, 175));
			    global.speaker_sprite[global.page_number] = spr_susie_dialogue;
				snd[global.page_number] = snd_susie;
			break;
			
			case "ralsei":
				scr_text_color_default(make_colour_rgb(77, 204, 142));
			    global.speaker_sprite[global.page_number] = spr_ralsei_dialogue;
				snd[global.page_number] = snd_ralsei;
			break;
			
			case "noelle":
				scr_text_color_default(make_colour_rgb(255, 253, 250));
			    global.speaker_sprite[global.page_number] = spr_noelle_dialogue;
				snd[global.page_number] = snd_noelle;
			break;
			
			case "sweet":
				scr_text_color_default(make_colour_rgb(170, 144, 207));
				snd[global.page_number] = snd_empty;
			break;
			
			case "k_k":
				scr_text_color_default(make_colour_rgb(105, 148, 121));
				snd[global.page_number] = snd_empty;
			break;
			
			case "cap'n":
				scr_text_color_default(make_colour_rgb(168, 163, 193));
				snd[global.page_number] = snd_empty;
			break;
			
			case "tenna":
			    scr_text_color_default(make_colour_rgb(181, 42, 79));
			    snd[global.page_number] = snd_tenna1;
			break;
			
			case "gerson":
				scr_text_color_default(make_colour_rgb(101, 170, 38));
				snd[global.page_number] = snd_gerson;
				snd_delay[global.page_number] = 4;
			break;
				
			case "jevil":
				scr_text_color_default(make_colour_rgb(109, 109, 192));
				snd[global.page_number] = snd_jevil;
			break;
			
			case "spamton":
				snd[global.page_number] = snd_spamton;
			break;
			
			case "mewmew":
			    scr_text_color_gradient(c_white, make_colour_rgb(255, 138, 144));
			    snd[global.page_number] = snd_empty;
			    speaker_portrait_spr[global.page_number] = spr_mewmewspeaker_talkhappy;

			    if (instance_exists(obj_mewmew) && obj_mewmew.corrupted == true) {
			        speaker_portrait_tail_spr[global.page_number] = spr_mewmewspeaker_tail_corrupted;
			    } else {
			        speaker_portrait_tail_spr[global.page_number] = spr_mewmewspeaker_tail;
			    }
			break;
			
			case "mewmewghost":
				scr_text_color_default(make_colour_rgb(199, 185, 215));
				snd[global.page_number] = snd_empty;
				speaker_portrait_spr[global.page_number] = spr_pinkghost_concerned;
				speaker_portrait_tail_spr[global.page_number] = spr_pinkghost_tail;
			break;
			
			case "knight":
				snd[global.page_number] = noone;
				scr_text_color_gradient(make_colour_rgb(160, 0, 10), make_colour_rgb(120, 0, 10));
			break;
			
			case "noone":
			    // no speaker_sprite set, text stays at default position
				snd[global.page_number] = noone;
			break;
			
			case "friend":
				snd[global.page_number] = snd_empty;
				scr_text_color_gradient(make_colour_rgb(255, 242, 0), make_colour_rgb(255, 174, 201));
			break;
			
			case "lancer":
				snd[global.page_number] = snd_lancer;
				global.speaker_sprite[global.page_number] = spr_lancer_dialogue;
				scr_text_color_default(make_colour_rgb(85, 133, 189));
			break;
			
			case "king":
				snd[global.page_number] = snd_king;
				global.speaker_sprite[global.page_number] = spr_king_dialogue;
				scr_text_color_default(make_colour_rgb(96, 128, 192));
			break;
			
			case "queen":
				snd[global.page_number] = snd_queen;
				global.speaker_sprite[global.page_number] = spr_queen_dialogue;
				scr_text_color_default(make_colour_rgb(111, 209, 255));
			break;
			
			case "empty":
			    // no speaker_sprite set, text stays at default position
				snd[global.page_number] = snd_empty;
			break;
			
		}
	}
	
	//sprite index of current character
	if argument_count > 2
	{
		global.speaker_image[global.page_number] = argument[2];
	}
	
	if argument_count > 3
	{
	    switch(argument[3])
	    {
	        case "silent":
	            snd[global.page_number] = noone;
	        break;
	    }
	}
	
	if argument_count > 4 && argument[4] == true
	{
	    freeze_anim_on_finish[global.page_number] = true;
	}
	
	if argument_count > 5 && argument[5] == true
	{
	    hide_face[global.page_number] = true;
	}
	
	global.page_number++;
}


/// @param option
/// @param link_id
function scr_option(_option, _link_id)
{
	option[global.option_number] = _option;
	option_link_id[global.option_number] = _link_id;
	
	global.option_number++;
}

/// @param text_id
function create_textbox(_text_id)
{
	draw_set_font(fnt_determination);
    with (instance_create_depth(0, 0, -10000, obj_textbox))
    {
        scr_game_text(_text_id);

        if (global.page_number == 0)
        {
            instance_destroy();
            if (instance_exists(obj_cutscenehandler_midfightattacks))
            {
                obj_cutscenehandler_midfightattacks.processing_queue = true;
            }
            exit;
        }

        global.page_number_real = global.page_number;
		//loop through the page numbers
        for (var p = 0; p < global.page_number; p++)
        {
            text_length[p] = string_length(text[p]);
            text_x_offset[p] = 5;

			if global.speaker_sprite[p] != noone
			{
			    var _portrait_w = sprite_get_width(global.speaker_sprite[p]);
			    text_x_offset[p] = _portrait_w + 56;
			}
			
			if speaker_portrait_spr[p] != noone
			{
			    text_x_offset_right[p] = sprite_get_width(speaker_portrait_spr[p]) + 20;
			}
			else
			{
			    text_x_offset_right[p] = 0;
			}
			
			for (var c = 0; c < text_length[p]; c++)
			{
				var _char_pos = c + 1;
				char[c, p] = string_char_at(text[p], _char_pos);
				var _text_up_to_char = string_copy(text[p], 1, _char_pos);
				var _current_text_w = string_width(_text_up_to_char) - string_width(char[c, p]);
				if char[c, p] = " " {global.last_free_space = _char_pos + 1};
				if _current_text_w - line_break_offset[p] > (line_width - text_x_offset[p] - text_x_offset_right[p]) / text_scale
				{
					manual_break[line_break_num[p], p] = false;
					line_break_pos[line_break_num[p], p] = global.last_free_space;
					line_break_num[p]++;
					var _text_up_to_last_space = string_copy(text[p], 1, global.last_free_space);
					var _last_free_space_string = string_char_at(text[p], global.last_free_space);
					line_break_offset[p] = string_width(_text_up_to_last_space) 
					    - string_width(_last_free_space_string) - string_width(" ");
				}
				if char[c, p] == "|"
				{
				    line_break_pos[line_break_num[p], p] = _char_pos + 1;
				    manual_break[line_break_num[p], p] = true;
				    line_break_num[p]++;
				    line_break_offset[p] = string_width(string_copy(text[p], 1, _char_pos + 1))
				        - string_width("|");
				}
			}
			
			for (var c = 0; c < text_length[p]; c++)
			{
				var _char_pos = c + 1;
				var _txt_x = textbox_x + text_x_offset[p] + border;
                var _txt_y = textbox_y + border;
				var _text_up_to_char = string_copy(text[p], 1, _char_pos);
				var _current_text_w = string_width(_text_up_to_char) - string_width(char[c, p]);
				var _txt_line = 0;
				var _is_manual = false;

				for (var lb = 0; lb < line_break_num[p]; lb++)
				{
				    if _char_pos >= line_break_pos[lb, p]
				    {
				        var _str_copy = string_copy(text[p], 
				            line_break_pos[lb, p], _char_pos - line_break_pos[lb, p]);
				        _current_text_w = string_width(_str_copy);
				        _txt_line = lb + 1;
				        _is_manual = manual_break[lb, p];
				    }
				}

				var _line_indent = (_txt_line > 0 && !_is_manual ? string_width("  ") : 0);
				char_x[c, p] = _txt_x + _current_text_w + _line_indent;
				char_y[c, p] = _txt_y + _txt_line * obj_textbox.line_sep;
				line_of_char[c, p] = _txt_line; // new — remember which line this character is on
			}
			
			line_min_x[0, p] = 999999;
			line_max_x[0, p] = -999999;
			for (var lb = 0; lb <= line_break_num[p]; lb++)
			{
			    line_min_x[lb, p] = 999999;
			    line_max_x[lb, p] = -999999;
			}
			for (var c = 0; c < text_length[p]; c++)
			{
			    var _l = line_of_char[c, p];
			    var _cx1 = char_x[c, p];
			    var _cx2 = char_x[c, p] + string_width(char[c, p]);
			    if (_cx1 < line_min_x[_l, p]) line_min_x[_l, p] = _cx1;
			    if (_cx2 > line_max_x[_l, p]) line_max_x[_l, p] = _cx2;
			}
        }
        setup = true;
    }
}

// ===== Knighting (King kneels, Knight's combined pose) =====
// spr_roark_knight_king / _hand have King baked in 41px (native) from their left edge,
// at the same top-left as spr_king_kneel_happy
#macro KNIGHTING_KING_OFFSET_X 41
// Knight's crown: last frame of spr_roark_ball_to_knight (36,8) vs knighting sprites (20,3)
#macro KNIGHT_STAND_TO_POSE_X 16
#macro KNIGHT_STAND_TO_POSE_Y 5

/// where King's x/y needs to be so the kneel sprite's feet (bottom-center of the
/// visible pixels) land where his current sprite's feet are
function scr_king_kneel_pos(_kneel_sprite = spr_king_kneel_happy)
{
    if (!instance_exists(obj_king)) return { x: 0, y: 0 };
    var _k   = obj_king;
    var _spr = _k.sprite_index;
    var _sx  = _k.image_xscale;
    var _sy  = _k.image_yscale;

    var _fx = _k.x + ((sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr) + 1) / 2 - sprite_get_xoffset(_spr)) * _sx;
    var _fy = _k.y + (sprite_get_bbox_bottom(_spr) + 1 - sprite_get_yoffset(_spr)) * _sy;

    return {
        x: _fx - ((sprite_get_bbox_left(_kneel_sprite) + sprite_get_bbox_right(_kneel_sprite) + 1) / 2 - sprite_get_xoffset(_kneel_sprite)) * _sx,
        y: _fy - (sprite_get_bbox_bottom(_kneel_sprite) + 1 - sprite_get_yoffset(_kneel_sprite)) * _sy
    };
}

/// where the Knight should hover so that swapping into the knighting pose doesn't jump him
function scr_knight_spot_by_king()
{
    var _k = scr_king_kneel_pos();
    var _s = 2; // obj_knight's image_xscale/yscale
    return {
        x: _k.x - (KNIGHTING_KING_OFFSET_X + KNIGHT_STAND_TO_POSE_X) * _s,
        y: _k.y - KNIGHT_STAND_TO_POSE_Y * _s
    };
}

function scr_king_kneel(_sprite = spr_king_kneel_happy)
{
    if (!instance_exists(obj_king)) exit;
    var _p = scr_king_kneel_pos(_sprite);
    with (obj_king)
    {
        pre_kneel_sprite = sprite_index;
        pre_kneel_x = x;
        pre_kneel_y = y;
        sprite_index = _sprite;
        image_index = 0;
        image_speed = 0;
        x = _p.x;
        y = _p.y;
    }
}

/// Knight takes over drawing King (he's baked into the sprite), real King hides
function scr_knighting_pose(_sprite = spr_roark_knight_king)
{
    if (!instance_exists(obj_knight) || !instance_exists(obj_king)) exit;
    with (obj_knight)
    {
        ball_phase = 0; // stop the hover bob, or King would float along with him
        sprite_index = _sprite;
        image_index = 0;
        image_speed = 0;
        anim_loop = false;
        x = obj_king.x - KNIGHTING_KING_OFFSET_X * image_xscale;
        y = obj_king.y;
    }
    obj_king.visible = false;
}

/// Knight back to his standing frame (crown stays put), King reappears standing
function scr_knighting_rise(_king_sprite = -1)
{
    if (instance_exists(obj_knight))
    {
        with (obj_knight)
        {
            sprite_index = spr_roark_ball_to_knight;
            image_speed = 0;
            image_index = image_number - 1;
            anim_loop = false;
            x -= KNIGHT_STAND_TO_POSE_X * image_xscale;
            y -= KNIGHT_STAND_TO_POSE_Y * image_yscale;
            start_y = y;
            bob_angle = 0;
            ball_phase = 3; // back to hovering
        }
    }
    if (instance_exists(obj_king))
    {
        with (obj_king)
        {
            visible = true;
            if (variable_instance_exists(id, "pre_kneel_sprite"))
            {
                sprite_index = pre_kneel_sprite;
                x = pre_kneel_x;
                y = pre_kneel_y;
            }
            if (_king_sprite != -1) sprite_index = _king_sprite;
            image_index = 0;
            image_speed = 0;
        }
    }
}