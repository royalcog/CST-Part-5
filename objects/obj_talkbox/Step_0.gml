var total_len = string_length(_layout_text);
if (hold_seconds > 0) {
    if (instance_exists(speaker) && speaker.image_index >= speaker.image_number - 1 && !keep_speaker_animating)
    {
        speaker.image_speed = 0;
    }
    hold_seconds = max(0, hold_seconds - 1);
    if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_shift) || keyboard_check(vk_control)) {
        char_index = total_len;
        char_timer = 0;
        hold_seconds = 0;
        pause_ptr = array_length(pause_events);
    }
    exit;
}
if (chars_per_s > 0) {
    if (char_index < total_len) {
        char_timer += chars_per_s;
        var adv = floor(char_timer);
        if (adv > 0) {
            char_index = clamp(char_index + adv, 0, total_len);
            
            var _cur_char = string_char_at(_layout_text, char_index);
            if _cur_char != " " && _cur_char != "\n" && speak_snd != noone
			{
			    if snd_count <= 0
			    {
			        if speak_snd == snd_queen
			        {
			            audio_stop_sound(snd_queen);
			            var _snd = audio_play_sound(snd_queen, 8, false);
			            audio_sound_pitch(_snd, 0.9 + random(0.15));
			            audio_sound_gain(_snd, speak_vol, 0);
			        }
			        else
			        {
			            var _snd = audio_play_sound(speak_snd, 8, false);
			            audio_sound_gain(_snd, speak_vol, 0);
			        }
			        snd_count = snd_delay * adv;
			    }
			    else
			    {
			        snd_count -= adv;
			    }
			}
            
            if instance_exists(obj_battat) && instance_exists(speaker) && speaker == obj_battat
            {
                obj_battat.talking = true;
            }
			if instance_exists(obj_jongler) && instance_exists(speaker) && speaker == obj_jongler
			{
			    obj_jongler.talking = true;
			}
			if instance_exists(obj_pluey) && instance_exists(speaker) && speaker == obj_pluey
			{
			    obj_pluey.talking = true;
			}
            
            if _cur_char == "@"
            {
                if instance_exists(obj_battat)
                {
                    scr_char_jolt(obj_battat, 3, 10);
                }
                else if instance_exists(speaker)
                {
                    scr_char_jolt(speaker, 3, 10);
                }
            }
            
            if (_cur_char == "$")
            {
                if (instance_exists(obj_tenna))
                {
					obj_tenna.use_battle_ext = false;
                    obj_tenna.sprite_index = spr_tenna_dance_cabbage;
                    obj_tenna.image_index = 0;
                    obj_tenna.image_speed = 1;
                    obj_tenna.anim_loop = true;
                }
            }
            
            if (_cur_char == "^")
			{
			    if (instance_exists(obj_tenna))
			    {
			        obj_tenna.animsiner = 0;
			        obj_tenna.animsinerb = 0;
			        obj_tenna.armshakesiner = 18;
			        obj_tenna.armshake = 1;
			        obj_tenna.use_battle_ext = true;
			    }
			}
			
			if (_cur_char == "`")
            {
                if (instance_exists(obj_tenna))
                {
					obj_tenna.use_battle_ext = false;
                    obj_tenna.sprite_index = spr_tenna_laugh;
                    obj_tenna.image_index = 0;
                    obj_tenna.image_speed = 1;
                    obj_tenna.anim_loop = true;
                }
            }
			
			if (_cur_char == "~")
            {
                if (instance_exists(obj_pluey))
                {
					obj_pluey.sprite_index = spr_pluey_sad;
                }
            }
			
			if (_cur_char == "+")
            {
                if (instance_exists(obj_pluey))
                {
					obj_pluey.sprite_index = spr_pluey;
                }
            }
            
            if (_cur_char == "#" && instance_exists(obj_noelle))
            {
                var _next = string_char_at(_layout_text, char_index + 1);
                obj_noelle.anim_pause_frame = real(_next);
                obj_noelle.anim_paused_for_talkbox = true;
                char_index = min(char_index + 1, total_len);
            }
			
            while (pause_ptr < array_length(pause_events) && char_index >= pause_events[pause_ptr].idx) {
			    hold_seconds = max(hold_seconds, pause_events[pause_ptr].sec * game_get_speed(gamespeed_fps));
			    pause_ptr++;
			}
            char_timer -= adv;

			var _bare_quote = string_replace(quote, "* ", "");
			if (animate_while_talking && base_animating && instance_exists(speaker) && !scr_is_punctuation_only(quote))
			{
			    speaker.image_speed = 1; // a letter was just typed — animate
			}
        }
    }
    if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_shift) || keyboard_check(vk_control)) {
        char_index = total_len;
        char_timer = 0;
        hold_seconds = 0;
        pause_ptr = array_length(pause_events);
    }
}
if (global.DEBUG_BARRAGE)
{
    end_hold_seconds = 9999;
}
else
{
    end_hold_seconds = clamp(1.5 + 0.015 * total_len, 1.5, 4.0);
}
if char_index >= total_len {
    if (instance_exists(speaker) && speaker.image_index >= speaker.image_number - 1 && !keep_speaker_animating)
    {
        speaker.image_speed = 0;
    }
    if instance_exists(obj_battat)
    {
        obj_battat.talking = false;
    }
	if instance_exists(obj_jongler) { obj_jongler.talking = false; }
	if instance_exists(obj_pluey) { obj_pluey.talking = false; }
    if (alarm[0] == -1) alarm[0] = ceil(end_hold_seconds * game_get_speed(gamespeed_fps));
    // instant_cutoff: skip the normal post-typing hold entirely — advance the instant typing finishes
    if instant_cutoff || ready_to_advance || keyboard_check_pressed(ord("Z")) 
    { 
        if instance_exists(obj_noelle)
        {
            obj_noelle.anim_paused_for_talkbox = false;
            obj_noelle.image_speed = 1;
        }
        instance_destroy();
    }
}