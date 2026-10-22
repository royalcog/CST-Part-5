if !ready { ready = true; exit; }
accept_key = keyboard_check_pressed(ord("Z"));

// apply facing for page 0
if !page0_applied
{
    page0_applied = true;
    if facing_change[0] != noone
    {
        obj_kris.face = facing_change[0];
        if facing_spr[0] != noone
        {
            obj_kris.sprite_override = facing_spr[0];
            obj_kris.sprite_index = facing_spr[0];
            obj_kris.image_index = 0;
        }
    }
}

//setup
draw_set_font(fnt_determination);
draw_set_valign(fa_top);
draw_set_halign(fa_left);

//typing the text
if text_pause_timer <= 0
{
    if draw_char < text_length[page]
    {
        var _check_char = string_char_at(text[page], draw_char);
    
        var _speed = text_speed_override[page] != noone ? text_speed_override[page] : text_speed;
        if text_cutoff_threshold[page] != noone && draw_char >= text_cutoff[page] - text_cutoff_threshold[page]
        {
            _speed = text_cutoff_speed[page];
        }

        if _check_char == "." || _check_char == "?" || _check_char == "!"
		{
		    var _next_char = string_char_at(text[page], draw_char + 1);
		    if _next_char == " " || _next_char == "" || _next_char == "|"
		    {
		        text_pause_timer = text_pause_time;
		    }
		}
        else if _check_char == ","
        {
            text_pause_timer = text_pause_time / 2;
        }
        else if _check_char != "*" && _check_char != " "
        {
            var _adjusted_delay = snd_delay[page] * (text_speed / _speed);
            if snd[page] == snd_tenna1
            {
                _adjusted_delay += 3;
            }
            if snd_count < _adjusted_delay
            {
                snd_count++;
            }
            else
            {
                snd_count = 0;
                if snd[page] != noone
				{
				    var _play_snd = snd[page];
				    if _play_snd == snd_queen
				    {
				        audio_stop_sound(snd_queen);
				        var _q_inst = audio_play_sound(snd_queen, 8, false);
				        audio_sound_pitch(_q_inst, 0.9 + random(0.15));
				    }
				    else if _play_snd == snd_tenna1
				    {
				        var _tenna_snds = [snd_tenna1, snd_tenna2, snd_tenna3, snd_tenna4, snd_tenna5,
				                           snd_tenna6, snd_tenna7, snd_tenna8, snd_tenna9, snd_tenna10];
				        _play_snd = _tenna_snds[irandom(9)];
				        audio_play_sound(_play_snd, 8, false);
				    }
				    else
				    {
				        audio_play_sound(_play_snd, 8, false);
				    }
				}
            }
        }
		
		if _check_char == "^"
		{
		    if instance_exists(obj_mewmew)
		    {
		        obj_mewmew.sprite_index = spr_mewmew_shocked_left;
		        obj_mewmew.image_index = 0;
		        obj_mewmew.image_speed = 1;
		        obj_mewmew.anim_loop = true;
		    }
		}

        draw_char += _speed;
        draw_char = clamp(draw_char, 0, text_length[page]);
    
        if text_cutoff[page] != noone && draw_char >= text_cutoff[page]
        {
            if (cutoff_skip[page])
            {
                // SKIP AHEAD — same behavior as the normal "flip through pages" logic
                if page < global.page_number - 1
                {
                    page++;
                    tail_anim_frame = 0;
                    tail_anim_done = false;
                    draw_char = 0;
                    secondary_draw_char = 0;
					secondary_wait_timer = 0;
                    secondary_snd_count = 0;
                    if facing_change[page] != noone
                    {
                        obj_kris.face = facing_change[page];
                        if facing_spr[page] != noone
                        {
                            obj_kris.sprite_override = facing_spr[page];
                            obj_kris.sprite_index = facing_spr[page];
                            obj_kris.image_index = 0;
                        }
                    }
                }
                else
                {
                    obj_dial_invis.alarm[0] = 1;
                    scr_text_speaker_shake_stop();
                    obj_kris.sprite_override = noone;
                    instance_destroy();
                }
            }
            else
            {
                obj_dial_invis.alarm[0] = 1;
                scr_text_speaker_shake_stop();
                obj_kris.sprite_override = noone;
                instance_destroy();
            }
        }
    }
}

else
{
    text_pause_timer--;
}

//flip through pages
if accept_key
{
    if draw_char == text_length[page]
    {
        if page < global.page_number - 1
        {
            page++;
            tail_anim_frame = 0;
            tail_anim_done = false;
            draw_char = 0;
            secondary_draw_char = 0;
			secondary_wait_timer = 0;
            secondary_snd_count = 0;
            if facing_change[page] != noone
            {
                obj_kris.face = facing_change[page];
                if facing_spr[page] != noone
                {
                    obj_kris.sprite_override = facing_spr[page];
                    obj_kris.sprite_index = facing_spr[page];
                    obj_kris.image_index = 0;
                }
            }
        }
        else
        {
            if global.option_number > 0
            {
                create_textbox(option_link_id[option_pos]);
            }
            obj_kris.sprite_override = noone;
            instance_destroy();
        }
    }
    else
    {
        draw_char = text_length[page];
    }
}

//draw the textbox
var _txtb_y = textbox_y;
txtb_spr_w = sprite_get_width(txtb_spr[page]);
txtb_spr_h = sprite_get_height(txtb_spr[page]);

if (!hide_box_sprite)
{
    draw_sprite_ext(txtb_spr[page], txtb_img, textbox_x, textbox_y,
        textbox_width/txtb_spr_w, textbox_height/txtb_spr_h, 0, c_white, 1);
}

if global.speaker_sprite[page] != noone && !global.hide_face && !hide_face[page]
{
    var _portrait_spr = global.speaker_sprite[page];
    var _portrait_x = textbox_x + global.portrait_x_offset[page] + 10;
    var _base_scale = ((textbox_height - border * 2) / sprite_get_height(_portrait_spr)) * 0.9;
    var _draw_scale = _base_scale;
    var _portrait_y_adjust = 0;

    if (_portrait_spr == spr_lancer_dialogue)
    {
        _draw_scale *= 1.15;
        _portrait_y_adjust = -8;
    }
    else if (_portrait_spr == spr_ralsei_dialogue)
    {
        _draw_scale *= 1.2;
        _portrait_y_adjust = -6;
    }

    var _portrait_w = sprite_get_width(_portrait_spr);
    draw_sprite_ext(_portrait_spr, global.speaker_image[page], _portrait_x + _portrait_w * _base_scale / 2,
        textbox_y + border + 8 + _portrait_y_adjust, global.speaker_side[page] * _draw_scale, _draw_scale, 0, c_white, 1);
}

//options
if draw_char == text_length[page] && page == global.page_number - 1
{
    option_pos += keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
    option_pos = clamp(option_pos, 0, global.option_number - 1);

    var _op_space = 17;
    var _op_bord = 4;
    for (var op = 0; op < global.option_number; op++)
    {
        var _op_w = string_width(option[op]) + _op_bord * 2;
        var _opb_spr_w = sprite_get_width(spr_optionbox);
        var _opb_spr_h = sprite_get_height(spr_optionbox);
        draw_sprite_ext(spr_optionbox, 0, textbox_x + border + 16,
            _txtb_y - _op_space * global.option_number + _op_space * op, _op_w/_opb_spr_w,
            (_op_space - 1)/_opb_spr_h, 0, c_white, 1);

        if option_pos == op
        {
            draw_sprite(spr_arrow, 0, textbox_x + border, _txtb_y - _op_space * global.option_number + _op_space * op);
        }

        draw_text(textbox_x + border + 16 + _op_bord, _txtb_y - _op_space * global.option_number + _op_space * op + 2, option[op]);
    }
}

// portrait animation
var _bare_text = string_replace(text[page], "* ", "");
if speaker_portrait_spr[page] != noone && !scr_is_punctuation_only(text[page])
{
    if draw_char < text_length[page]
    {
        portrait_anim_frame += portrait_anim_speed;
        if portrait_anim_frame >= sprite_get_number(speaker_portrait_spr[page])
            portrait_anim_frame = 0;
    }
    else
    {
        if portrait_anim_frame > 0
        {
            portrait_anim_frame += portrait_anim_speed;
            if portrait_anim_frame >= sprite_get_number(speaker_portrait_spr[page])
                portrait_anim_frame = 0;
        }
    }
}

var _center_offset = 0;
if (center_text)
{
    var _view_w = camera_get_view_width(view_camera[0]);
    _center_offset = (_view_w / 2) - (textbox_x + textbox_width / 2);
}

// draw the text
var _max_char = text_cutoff[page] != noone ? min(draw_char, text_cutoff[page]) : draw_char;
var _text_x_offset_draw = (global.hide_face || hide_face[page]) ? 5 : text_x_offset[page];
for (var c = 0; c < _max_char; c++)
{
    var _float_y = 0;
    if float_text[c, page] == true
    {
        float_dir[c, page] -= 6;
        _float_y = dsin(float_dir[c, page]);
    }

    var _shake_x = 0;
    var _shake_y = 0;
    if shake_text[c, page] == true
    {
        shake_timer[c, page]--;
        if shake_timer[c, page] <= 0
        {
            shake_timer[c, page] = irandom_range(4, 8);
            shake_dir[c, page] = irandom(360);
        }
        if shake_timer[c, page] <= 2
        {
            _shake_x = lengthdir_x(1, shake_dir[c, page]);
            _shake_y = lengthdir_y(1, shake_dir[c, page]);
        }
    }

    if char[c, page] != "|" && char[c, page] != "^" 
    {
        draw_text_transformed_color(
            textbox_x + border + _text_x_offset_draw + (char_x[c, page] - textbox_x - border - text_x_offset[page]) * text_scale + _shake_x + 5,
            textbox_y + border + (char_y[c, page] - textbox_y - border) * text_scale + _float_y + _shake_y + 3,
            char[c, page], text_scale, text_scale, 0,
            col_1[c, page], col_2[c, page], col_3[c, page], col_4[c, page], 1);
    }
}

// draw portrait
if speaker_portrait_spr[page] != noone
{
    var _px = textbox_x + textbox_width - 200;
    var _py = textbox_y + textbox_height - 240;
    draw_sprite_ext(speaker_portrait_spr[page], floor(portrait_anim_frame), _px, _py, 2, 2, 0, c_white, 1);
}

// tail animation and draw
if speaker_portrait_tail_spr[page] != noone
{
    if !tail_anim_done
    {
        tail_anim_frame += portrait_anim_speed;
        if tail_anim_frame >= sprite_get_number(speaker_portrait_tail_spr[page])
        {
            tail_anim_frame = sprite_get_number(speaker_portrait_tail_spr[page]) - 1;
            tail_anim_done = true;
            tail_loop_timer = 0;
        }
    }
    else
    {
        tail_loop_timer++;
        if tail_loop_timer >= tail_loop_delay
        {
            tail_anim_frame = 0;
            tail_anim_done = false;
        }
    }
    
    var _px = textbox_x + textbox_width - 200;
    var _py = textbox_y + textbox_height - 240;
    var _pscale = ((textbox_height - border * 2) / sprite_get_height(speaker_portrait_tail_spr[page])) * 0.9;
    draw_sprite_ext(speaker_portrait_tail_spr[page], floor(tail_anim_frame), _px, _py, 2, 2, 0, c_white, 1);
}

// secondary (mini, borderless "aside") textbox — types out once the main line finishes
if secondary_text[page] != ""
{
    var _sec_length = string_length(secondary_text[page]);
    var _sec_prev_chars = floor(secondary_draw_char);

    if (draw_char >= text_length[page]) && (secondary_draw_char < _sec_length)
	{
	    if secondary_wait_timer < secondary_wait_time
	    {
	        secondary_wait_timer++;
	    }
	    else
	    {
	        var _sec_speed = text_speed_override[page] != noone ? text_speed_override[page] : text_speed;
			secondary_draw_char += _sec_speed;
	        secondary_draw_char = clamp(secondary_draw_char, 0, _sec_length);

	        // play the speaker's tick sound as new characters get revealed
	        var _sec_new_chars = floor(secondary_draw_char);
	        if _sec_new_chars > _sec_prev_chars && secondary_snd[page] != noone
	        {
	            var _sec_check_char = string_char_at(secondary_text[page], _sec_new_chars);
	            if _sec_check_char != "*" && _sec_check_char != " "
	            {
	                if secondary_snd_count < secondary_snd_delay[page]
					{
					    secondary_snd_count++;
					}
					else
					{
					    secondary_snd_count = 0;

					    if secondary_snd[page] == snd_queen
					    {
					        audio_stop_sound(snd_queen);
					        var _sec_q_inst = audio_play_sound(snd_queen, 8, false);
					        audio_sound_pitch(_sec_q_inst, 0.9 + random(0.15));
					    }
					    else
					    {
					        audio_play_sound(secondary_snd[page], 8, false);
					    }
					}
	            }
	        }
	    }
	}

    var _sec_str = string_copy(secondary_text[page], 1, floor(secondary_draw_char));

    if (string_length(_sec_str) > 0)
	{
	    var _sec_scale = 1;
	    var _sec_margin_x = 14;
	    var _sec_margin_y = 10;
	    var _sec_base_portrait_scale = 0.7;
	    var _sec_draw_portrait_scale = _sec_base_portrait_scale;
	    var _sec_portrait_y_adjust = -60;
	    var _sec_portrait_x_adjust = 0;
	    var _sec_text_x_adjust = 0;
	    var _sec_text_y_adjust = 0;

	    if (secondary_portrait_spr[page] == spr_lancer_dialogue)
	    {
	        _sec_draw_portrait_scale *= 1.15;
	    }
	    else if (secondary_portrait_spr[page] == spr_ralsei_dialogue)
	    {
	        _sec_draw_portrait_scale *= 1.15;
	        _sec_portrait_y_adjust = -18;
	        _sec_text_y_adjust = 4;
	    }
	    else if (secondary_portrait_spr[page] == spr_queen_dialogue)
	    {
	        _sec_draw_portrait_scale *= 1.4;
	        _sec_portrait_y_adjust = -24;
	        _sec_text_y_adjust = -4;
	    }
		else if (secondary_portrait_spr[page] == spr_susie_dialogue)
	    {
	        _sec_draw_portrait_scale *= 1.15;
	        _sec_portrait_y_adjust = -18;
	        _sec_text_y_adjust = 4;
	    }
	    var _sec_h = string_height("Ay") * _sec_scale;
	    var _sec_anchor_x = textbox_x + textbox_width - 220;
	    var _sec_y_adjust = -20;
	    var _sec_col = secondary_col[page];

	    var _sec_has_portrait = (secondary_portrait_spr[page] != noone);
	    var _sec_portrait_w = _sec_has_portrait ? sprite_get_width(secondary_portrait_spr[page]) * _sec_base_portrait_scale : 0;
	    var _sec_x_text = _sec_anchor_x + (_sec_has_portrait ? _sec_portrait_w + _sec_margin_x : 0);
	    var _sec_max_w = (textbox_x + textbox_width - border) - (_sec_x_text + _sec_text_x_adjust);

	    // pre-count total lines the FULL text will need, so the block grows upward
	    // from a fixed bottom anchor instead of overflowing past the box
	    var _sec_total_lines = 0;
	    var _sec_count_str = "";
	    var _sec_full_len = string_length(secondary_text[page]);
	    for (var i = 1; i <= _sec_full_len; i++)
	    {
	        var _ch2 = string_char_at(secondary_text[page], i);
	        var _test2 = _sec_count_str + _ch2;
	        if (string_width(_test2) * _sec_scale > _sec_max_w && _sec_count_str != "")
	        {
	            var _break2 = string_last_pos(" ", _sec_count_str);
	            _sec_count_str = (_break2 > 0)
	                ? string_copy(_sec_count_str, _break2 + 1, string_length(_sec_count_str) - _break2) + _ch2
	                : _ch2;
	            _sec_total_lines++;
	        }
	        else
	        {
	            _sec_count_str = _test2;
	        }
	    }

	    var _sec_portrait_y = textbox_y + textbox_height - _sec_h - _sec_margin_y + _sec_y_adjust;
		var _sec_y = _sec_portrait_y - (_sec_total_lines * _sec_h);

	    if (_sec_has_portrait)
		{
		    draw_sprite_ext(secondary_portrait_spr[page], secondary_image[page], _sec_anchor_x + _sec_portrait_w / 2 + _sec_portrait_x_adjust,
		        _sec_portrait_y + _sec_portrait_y_adjust, secondary_side[page] * _sec_draw_portrait_scale,
		        _sec_draw_portrait_scale, 0, c_white, 1);
		}

	    draw_set_font(fnt_determination);
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);

	    var _sec_line_str = "";
	    var _sec_line_num = 0;
	    var _sec_char_count = string_length(_sec_str);

	    for (var i = 1; i <= _sec_char_count; i++)
	    {
	        var _ch = string_char_at(_sec_str, i);
	        var _test_line = _sec_line_str + _ch;

	        if (string_width(_test_line) * _sec_scale > _sec_max_w && _sec_line_str != "")
	        {
	            var _break_at = string_last_pos(" ", _sec_line_str);

	            if (_break_at > 0)
	            {
	                draw_text_transformed_color(_sec_x_text + _sec_text_x_adjust, _sec_y + _sec_text_y_adjust + _sec_line_num * _sec_h,
	                    string_copy(_sec_line_str, 1, _break_at - 1), _sec_scale, _sec_scale, 0,
	                    _sec_col, _sec_col, _sec_col, _sec_col, 1);
	                _sec_line_str = string_copy(_sec_line_str, _break_at + 1, string_length(_sec_line_str) - _break_at) + _ch;
	            }
	            else
	            {
	                draw_text_transformed_color(_sec_x_text + _sec_text_x_adjust, _sec_y + _sec_text_y_adjust + _sec_line_num * _sec_h,
	                    _sec_line_str, _sec_scale, _sec_scale, 0,
	                    _sec_col, _sec_col, _sec_col, _sec_col, 1);
	                _sec_line_str = _ch;
	            }
	            _sec_line_num++;
	        }
	        else
	        {
	            _sec_line_str = _test_line;
	        }
	    }

	    draw_text_transformed_color(_sec_x_text + _sec_text_x_adjust, _sec_y + _sec_text_y_adjust + _sec_line_num * _sec_h,
	        _sec_line_str, _sec_scale, _sec_scale, 0,
	        _sec_col, _sec_col, _sec_col, _sec_col, 1);
	}
}