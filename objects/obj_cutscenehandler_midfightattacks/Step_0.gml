/*if (room == rm_two && !instance_exists(obj_mewmew)) 
{
    // If you are in the new room but Mewmew hasn't been spawned yet,
    // wait for the Room Start event to finish spawning her.
    exit; 
}
*/

var _textbox_open = instance_exists(obj_textbox);
var _textbox_just_closed = textbox_was_open && !_textbox_open;
textbox_was_open = _textbox_open;

// If the textbox just closed this frame, automatically engage the queue trigger!
if (_textbox_just_closed)
{
    processing_queue = true;
    page_loop_objs = [];
    page_move_active = [];
}

// 1. FIRE SPRITE_QUEUE ON CURRENT PAGE
if instance_exists(obj_textbox)
{
    for (var i = array_length(sprite_queue) - 1; i >= 0; i--)
    {
        var _entry = sprite_queue[i];
        if obj_textbox.page == _entry.page
        {
            if _entry.type == "spawn"
			{
			    instance_create_layer(_entry.x, _entry.y, _entry.layer, _entry.obj);
			    if (variable_struct_exists(_entry, "snd") && _entry.snd != noone)
			    {
			        audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
			    }
			    array_delete(sprite_queue, i, 1);
			}
            else if _entry.type == "sprite" && instance_exists(_entry.obj)
			{
			    _entry.obj.sprite_index = _entry.sprite;
			    _entry.obj.anim_loop = _entry.loop;
			    _entry.obj.image_speed = _entry.loop ? 1 : 0;
			    _entry.obj.image_index = _entry.image;
			    if _entry.snd != noone
			    {
			        audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
			    }
			    array_delete(sprite_queue, i, 1);

			    if (_entry.loop)
			    {
			        array_push(page_loop_objs, { obj: _entry.obj, page: _entry.page });
			    }
			}
			else if _entry.type == "fade_special"
			{
			    trigger_fade_special_sprite(_entry.target_object, _entry.sprite, _entry.image, _entry.fade_speed);
			    array_delete(sprite_queue, i, 1);
			}
			else if _entry.type == "object_fade"
			{
			    trigger_object_fade(_entry.target_object, _entry.sprite, _entry.image, _entry.target_x, _entry.target_y, _entry.fade_speed);
			    array_delete(sprite_queue, i, 1);
			}
			else if _entry.type == "move_start"
			{
			    _entry.obj.sprite_index = _entry.sprite;
			    _entry.obj.image_index = 0;
			    _entry.obj.image_speed = _entry.loop ? 1 : 0;
			    _entry.obj.anim_loop = _entry.loop;

			    array_push(page_move_active, {
			        obj: _entry.obj,
			        dx: _entry.dx,
			        dy: _entry.dy,
			        speed: _entry.speed,
			        duration: _entry.duration,
			        timer: 0,
			        page: _entry.page,
			        ease: _entry[$ "ease"] ?? "none"
			    });

			    array_delete(sprite_queue, i, 1);
			}
			else if _entry.type == "set_var_page" && instance_exists(_entry.obj)
			{
			    variable_instance_set(_entry.obj, _entry.var_name, _entry.value);
			    array_delete(sprite_queue, i, 1);
			}
			else if _entry.type == "damage_number"
			{
			    scr_show_damage(_entry.obj, _entry.amount, _entry.color_top, _entry.color_bottom);
			    array_delete(sprite_queue, i, 1);
			}
			else if _entry.type == "ghost_sync" && instance_exists(_entry.obj)
			{
			    _entry.obj.start_y = _entry.obj.y; // resync bob center to wherever she actually is now
			    _entry.obj.ghosted = true;
			    array_delete(sprite_queue, i, 1);
			}
			else if _entry.type == "sound"
			{
			    audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
			    array_delete(sprite_queue, i, 1);
			}
			else if _entry.type == "layer_visible"
			{
			    var _lyr = layer_get_id(_entry.layer_name);
			    if (_lyr != -1)
			    {
			        layer_set_visible(_lyr, _entry.visible);
			    }
			    if (variable_struct_exists(_entry, "snd") && _entry.snd != noone)
			    {
			        audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
			    }
			    array_delete(sprite_queue, i, 1);
			}
			else if _entry.type == "sprite_once" && instance_exists(_entry.obj)
			{
			    _entry.obj.sprite_index = _entry.sprite;
			    _entry.obj.image_index = _entry.image;
			    _entry.obj.image_speed = 1;
			    _entry.obj.anim_loop = false;
			    if _entry.snd != noone
			    {
			        audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
			    }
			    array_delete(sprite_queue, i, 1);
			}
        }
    }
}

// 1b. FIRE DELAYED SPRITE_QUEUE (only counts down while its page is active)
if instance_exists(obj_textbox)
{
    for (var i = array_length(sprite_queue_delayed) - 1; i >= 0; i--)
    {
        var _entry = sprite_queue_delayed[i];
        if (obj_textbox.page == _entry.page)
        {
            _entry.delay -= 1;
                        if (_entry.delay <= 0)
            {
                if (variable_struct_exists(_entry, "is_custom_call") && _entry.is_custom_call)
                {
                    _entry.call_func();
                }
                else if (variable_struct_exists(_entry, "type") && _entry.type == "layer_visible")
				{
				    var _lyr = layer_get_id(_entry.layer_name);
				    if (_lyr != -1)
				    {
				        layer_set_visible(_lyr, _entry.visible);
				    }
				    if (variable_struct_exists(_entry, "snd") && _entry.snd != noone)
				    {
				        audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
				    }
				}
                else if (instance_exists(_entry.obj))
				{
				    _entry.obj.sprite_index = _entry.sprite;
				    _entry.obj.image_index = _entry.image;
				    _entry.obj.image_speed = _entry.loop ? 1 : 0;
				    _entry.obj.anim_loop = _entry.loop;
				    if (_entry.snd != noone)
				    {
				        audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
				    }

				    if (_entry.loop) // <-- new
				    {
				        array_push(page_loop_objs, { obj: _entry.obj, page: _entry.page });
				    }
				}
				array_delete(sprite_queue_delayed, i, 1);
            }
        }
    }
}

if instance_exists(obj_textbox)
{
    var _typing = (obj_textbox.draw_char < obj_textbox.text_length[obj_textbox.page]);
    var _should_freeze = !_typing && obj_textbox.freeze_anim_on_finish[obj_textbox.page];

    for (var i = 0; i < array_length(page_loop_objs); i++)
    {
        var _e = page_loop_objs[i];
        if (_e.page == obj_textbox.page && instance_exists(_e.obj))
        {
            _e.obj.image_speed = _should_freeze ? 0 : 1;
        }
    }
}

// 2. TEXTBOX JUST CLOSED - PROCESS AFTER_TEXTBOX_QUEUE
if (processing_queue)
{
    if (array_length(move_queue_active) > 0)
    {
        exit;
    }

    while (array_length(after_textbox_queue) > 0)
    {
        var _entry = after_textbox_queue[0];
        array_delete(after_textbox_queue, 0, 1);

        if _entry.type == "spawn"
        {
            instance_create_layer(_entry.x, _entry.y, _entry.layer, _entry.obj);
            if _entry.snd != noone
            {
                audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
            }
        }
        else if _entry.type == "sprite" && instance_exists(_entry.obj)
        {
            _entry.obj.sprite_index = _entry.sprite;
            _entry.obj.image_index = _entry.image;
            _entry.obj.image_speed = _entry.loop ? 1 : 0;
            _entry.obj.anim_loop = _entry.loop;
            if _entry.snd != noone
            {
                audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
            }
        }
        else if _entry.type == "sound"
		{
		    if _entry.snd != noone
		        audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
		}
		else if _entry.type == "layer_visible"
		{
		    var _lyr = layer_get_id(_entry.layer_name);
		    if (_lyr != -1)
		    {
		        layer_set_visible(_lyr, _entry.visible);
		    }
		    if (variable_struct_exists(_entry, "snd") && _entry.snd != noone)
		    {
		        audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
		    }
		}
        else if _entry.type == "tenna_shake"
        {
            scr_tenna_shake(_entry.state);
        }
        else if _entry.type == "blackbox"
        {
            var _bb = instance_create_layer(_entry.x, _entry.y, _entry.layer, _entry.obj);
            obj_cutscenehandler_midfightattacks.blackbox_instance = _bb;
            if _entry.snd != noone
            {
                audio_stop_all();
                audio_play_sound(_entry.snd, 10, false, _entry.snd_gain);
            }
            else
            {
                audio_stop_all();
            }
        }
        else if _entry.type == "tenna_battle_intro"
        {
            tenna_battle_intro_state = 1;
        }
        else if _entry.type == "knight_ball"
        {
            scr_roark_ball_start();
        }
        else if _entry.type == "impact_sequence"
        {
            audio_sound_gain(global.music, 0);
            impact_seq_state = 1;
        }
        else if _entry.type == "knight_to_ball"
        {    
            audio_sound_gain(global.music, 0, 100);
            scr_knight_to_ball();
        }
        else if (_entry.type == "villains_ascend" && villains_ascending == false)
		{
		    villains_ascending = true; // This instantly locks the door behind it
    
		    if instance_exists(obj_jevil)
		    {
		        audio_play_sound(snd_sparklegem, 1, false);
		        obj_jevil.sprite_index = spr_devilsknife;
		        obj_jevil.image_index = 0;
		        obj_jevil.image_speed = 1;
		        obj_jevil.anim_loop = true;
		    }
		    if instance_exists(obj_spamton)
		    {
		        obj_spamton.sprite_index = spr_dealmaker;
		        obj_spamton.image_index = 0;
		        obj_spamton.image_speed = 1;
		        obj_spamton.anim_loop = true;
		    }
		}
		else if (_entry.type == "villains_descend" && villains_descending == false)
		{
		    villains_descending = true; // Lock the block so it only fires once

		    var _drop_height = 140; // how far above the landing spot they start

		    var _jevil_target_x = 460;
		    var _jevil_target_y = 340;

		    if (!instance_exists(obj_jevil))
		    {
		        audio_play_sound(snd_sparklegem, 1, false);
		        var _jevil = instance_create_layer(_jevil_target_x, _jevil_target_y - _drop_height, "Instances", obj_jevil);

		        with (_jevil) {
		            in_cutscene = true; 
		            image_alpha = 0;
		            sprite_index = spr_devilsknife;
		            image_index = 0;
		            image_speed = 1;
		            anim_loop = true;
		            target_x = _jevil_target_x;
		            target_y = _jevil_target_y;
		        }
		    }

		    var _spamton_target_x = 380;
		    var _spamton_target_y = 340;

		    if (!instance_exists(obj_spamton))
		    {
		        var _spamton = instance_create_layer(_spamton_target_x, _spamton_target_y - _drop_height, "Instances", obj_spamton);

		        with (_spamton) {
		            image_alpha = 0;
		            sprite_index = spr_dealmaker;
		            image_index = 0;
		            image_speed = 1;
		            anim_loop = true;
		            target_x = _spamton_target_x;
		            target_y = _spamton_target_y;
		        }
		    }
		}
        else if _entry.type == "fade_out_to_black"
		{
		    if (!instance_exists(obj_cutscenefade))
		    {
		        var _fader = instance_create_depth(0, 0, -9999, obj_cutscenefade);
		        _fader.fade_target = 1;
		        _fader.target_room = room; 
        
		        // Optional check: if your struct has a color specified, use it!
		        if (variable_struct_exists(_entry, "fade_color"))
		        {
		            _fader.fade_color = _entry.fade_color; // Pass c_white here if desired
		        }
		    }
		    break; 
		}
        else if _entry.type == "warp_and_fade_in"
        {
            // IF SHE IS STILL WALKING, PUT IT BACK IN THE QUEUE AND WAIT!
            if (array_length(move_queue_active) > 0)
            {
                // This puts the warp back at the start of the queue so it's checked again next frame
                array_insert(after_textbox_queue, 0, _entry);
                break; 
            }
            
            // OTHERWISE, IF NO ONE IS WALKING, DO THE FADE!
            if (!instance_exists(obj_cutscenefade))
            {
                var _fader = instance_create_depth(0, 0, -9999, obj_cutscenefade);
                _fader.fade_target = 1;
                _fader.target_room = _entry.target_room; 
            }
            // We deleted the entry from the queue at the start of the while loop, 
            // so we don't need to do anything else here.
        }
		else if _entry.type == "orb_shake"
		{
			obj_orb.alarm[0] = 120;
		}
        else if _entry.type == "char_move"
        {
            array_push(move_queue_active, {
                obj: _entry.obj,
                sprite: _entry.sprite,
                loop: _entry.loop,
                dx: _entry.dx,
                dy: _entry.dy,
                speed: _entry.speed,
                duration: _entry.duration,
                timer: 0,
                started: false,
                fade_out: variable_struct_exists(_entry, "fade_out") ? _entry.fade_out : false,
                fade_speed: variable_struct_exists(_entry, "fade_speed") ? _entry.fade_speed : 0.05,
                fading: false,
				ease: _entry[$ "ease"] ?? "none"
            });
            break; 
        }
		else if _entry.type == "CTSP"
		{
			trigger_shadow_pause(_entry.target_object, _entry.sprite, _entry.wait_seconds);
		}
		else if _entry.type == "PAUSE_ONLY"
		{
		    trigger_pause_only(_entry.target_object, _entry.wait_seconds);
		}
		else if _entry.type == "RESUME_SCROLL"
		{
		    trigger_resume_scrolling(_entry.target_object);
		}
		else if _entry.type == "FADE_SPECIAL"
		{
		    trigger_fade_special_sprite(_entry.target_object, _entry.sprite, _entry.image, _entry.fade_speed);
		}
		else if _entry.type == "OBJECT_FADE"
		{
		    trigger_object_fade(_entry.target_object, _entry.sprite, _entry.image, _entry.target_x, _entry.target_y, _entry.fade_speed);
		}
		else if _entry.type == "impact_flash"
		{
		    impact_flash_target = instance_find(_entry.target_obj, 0);
		    impact_flash_silhouette_spr = _entry.silhouette_spr;
		    impact_flash_circle_speed = _entry.circle_speed;
		    impact_flash_hit_sprite = _entry.hit_sprite;
		    impact_flash_yelling_sprite = _entry.yelling_sprite;
		    impact_flash_knockback_speed = _entry.knockback_speed;
		    impact_flash_knockback_friction = _entry.knockback_friction;
		    impact_flash_next_text_id = _entry.next_text_id;
		    impact_flash_wait_duration = _entry.wait_frames;
		    impact_flash_knockback_dir = _entry.knockback_dir;
		    impact_flash_gerson_obj = _entry.gerson_obj;
		    impact_flash_gerson_speed = _entry.gerson_speed;
		    impact_flash_gerson_dir = _entry.gerson_dir;
		    impact_flash_gerson_friction = _entry.gerson_friction;
		    impact_flash_darken_alpha = 0;
		    impact_flash_circle_alpha = 0;
		    impact_flash_wait_timer = impact_flash_wait_duration;
		    impact_flash_circle_x = _entry.circle_start_x;
		    impact_flash_circle_y = _entry.circle_start_y;
		    impact_flash_spawn_obj = _entry.spawn_obj;
			impact_flash_original_sprite = _entry.original_sprite;
		    audio_stop_all(); 

		    impact_flash_state = 1;
		    break;
		}
		else if _entry.type == "set_var" && instance_exists(_entry.obj)
		{
		    variable_instance_set(_entry.obj, _entry.var_name, _entry.value);
		}
		else if _entry.type == "fade_warp_music"
		{
		    var _carry_alpha = 0;
		    if (instance_exists(obj_cutscenefade))
		    {
		        _carry_alpha = obj_cutscenefade.fade_alpha;
		        with (obj_cutscenefade) { instance_destroy(); }
		    }

		    var _fader = instance_create_depth(0, 0, -9999, obj_cutscenefade);
		    _fader.fade_target = 1;
		    _fader.fade_alpha = _carry_alpha;
		    _fader.target_room = _entry.target_room;
		    _fader.wait_duration = _entry.wait_frames;
		    _fader.new_music_sound = _entry.new_sound;
		    _fader.new_music_gain = _entry.new_gain;
		    _fader.new_music_fade_time = _entry.fade_in_time;
		    _fader.old_music_fade_time = _entry.fade_out_time;
		    _fader.music_lead_frames = _entry.music_lead_frames;
			_fader.spawn_list = variable_struct_exists(_entry, "spawn_list") ? _entry.spawn_list : [];
			_fader.fade_step  = 1 / max(1, variable_struct_exists(_entry, "fade_frames") ? _entry.fade_frames : 100);
			global.warp_pending = false;
		    break;
		}
		
		else if _entry.type == "damage_number" && instance_exists(_entry.obj)
		{
		    scr_show_damage(_entry.obj, _entry.amount, _entry.color_top, _entry.color_bottom);
		}
		
		else if _entry.type == "movement_group"
		{
		    array_push(movement_queue, { moves: _entry.moves });
		}
		else if (_entry.type == "fade")
		{
		    if (!instance_exists(obj_cutscenefade))
		    {
		        var _fader = instance_create_depth(0, 0, -9999, obj_cutscenefade);
		        _fader.fade_target = 1;
		        _fader.target_room = room; 
		        _fader.fade_color = _entry.fade_color;
		        _fader.fade_back_same_room = _entry.fade_back_same_room;
		        _fader.flash_wait_duration = _entry.wait_duration;
				_fader.hold_black = variable_struct_exists(_entry, "hold_black") ? _entry.hold_black : false;
				
		    }
		}
		else if _entry.type == "spawn_fade_in"
		{
		    var _inst = instance_create_layer(_entry.x, _entry.y, _entry.layer, _entry.obj);
		    _inst.image_alpha = 0;
		    _inst.fade_in_speed = _entry.fade_speed;
		    _inst.fading_in = true;
		}
		else if _entry.type == "fist_split"
		{
		    scr_fist_slam_split(obj_fist_slam_cutscene, _entry.edge_margin, _entry.lerp_speed, _entry.fade_speed);
		}
		else if _entry.type == "sparkle_heroes"
		{
		    scr_sparkle_heroes(_entry.heroes);
		}
		else if _entry.type == "sr_battle_intro"
		{
		    sr_battle_intro_state = 1;
		}
    }

    if (array_length(after_textbox_queue) == 0 && !instance_exists(obj_cutscenefade) && array_length(move_queue_active) == 0)
    {
        processing_queue = false;
        
        for (var i = 0; i < array_length(pending_delayed_queue); i++)
        {
            array_push(after_textbox_delayed_queue, pending_delayed_queue[i]);
        }
        pending_delayed_queue = [];
        
        if (array_length(after_textbox_delayed_queue) > 0)
        {
            after_queue_armed = true;
        }
    }
}

// 3. AMBIENT AUDIO LOGIC
if blackbox_sound_asset != noone && (blackbox_sound == noone || !audio_is_playing(blackbox_sound))
{
    blackbox_sound = audio_play_sound(blackbox_sound_asset, 10, false, 1);
}

// 4. FIRE DELAYED QUEUE
if after_queue_armed && array_length(after_textbox_delayed_queue) > 0
{
    for (var i = array_length(after_textbox_delayed_queue) - 1; i >= 0; i--)
    {
        after_textbox_delayed_queue[i].delay -= 1;
        if after_textbox_delayed_queue[i].delay <= 0
        {
            var _entry = after_textbox_delayed_queue[i];
            
            if (variable_struct_exists(_entry, "is_movement") && !variable_struct_exists(_entry, "obj"))
            {
                array_delete(after_textbox_delayed_queue, i, 1);
                continue;
            }
            
            if (variable_struct_exists(_entry, "is_sound_stop") && _entry.is_sound_stop)
			{
			    if (audio_is_playing(_entry.sound_inst))
			    {
			        audio_stop_sound(_entry.sound_inst);
			    }
			    array_delete(after_textbox_delayed_queue, i, 1);
			    continue;
			}

			if (variable_struct_exists(_entry, "is_layer_toggle") && _entry.is_layer_toggle)
			{
			    var _lyr = layer_get_id(_entry.layer_name);
			    if (_lyr != -1)
			    {
			        layer_set_visible(_lyr, _entry.visible);
			    }
			    if (variable_struct_exists(_entry, "snd") && _entry.snd != noone)
			    {
			        audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
			    }
			    array_delete(after_textbox_delayed_queue, i, 1);
			    continue;
			}
			
            if (variable_struct_exists(_entry, "is_teleport") && _entry.is_teleport)
            {
                if (instance_exists(_entry.obj))
                {
                    _entry.obj.x = _entry.x;
                    _entry.obj.y = _entry.y;
                    if (_entry.sprite != noone)
                    {
                        _entry.obj.sprite_index = _entry.sprite;
                        _entry.obj.image_index = _entry.image_index;
                    }
                }
                array_delete(after_textbox_delayed_queue, i, 1);
                continue;
            }

            if variable_struct_exists(_entry, "wait_for_anim") && _entry.wait_for_anim
            {
                if instance_exists(_entry.obj) && _entry.obj.image_speed != 0
                {
                    continue;
                }
            }
            
            if (variable_struct_exists(_entry, "is_damage_number") && _entry.is_damage_number)
            {
                if (instance_exists(_entry.obj))
                {
                    scr_show_damage(_entry.obj, _entry.amount, _entry.color_top, _entry.color_bottom);
                }
                array_delete(after_textbox_delayed_queue, i, 1);
                continue;
            }
            
            if (variable_struct_exists(_entry, "is_custom_call") && _entry.is_custom_call)
            {
                _entry.call_func();
                array_delete(after_textbox_delayed_queue, i, 1);
                continue;
            }
            
            // ---> MOVE FADE CHECK UP HERE, BEFORE instance_exists(_entry.obj) <---
            if (variable_struct_exists(_entry, "type") && _entry.type == "fade")
			{
			    if (!instance_exists(obj_cutscenefade))
			    {
			        var _fader = instance_create_depth(0, 0, -9999, obj_cutscenefade);
			        _fader.fade_target = 1;
			        _fader.target_room = room; 
			        _fader.fade_color = _entry.fade_color;
			        _fader.fade_back_same_room = _entry.fade_back_same_room;
			        _fader.flash_wait_duration = _entry.wait_duration;
			        _fader.hold_black = variable_struct_exists(_entry, "hold_black") ? _entry.hold_black : false;   // <-- was missing
			    }

			    array_delete(after_textbox_delayed_queue, i, 1);
			    continue; 
			}
            
            if instance_exists(_entry.obj)
            {
                if (_entry[$ "is_movement"] ?? false)
                {
                     array_push(move_queue_active, {
                        obj:          _entry.obj,
                        sprite:       _entry.sprite,
                        loop:         _entry.loop,
                        dx:           _entry.dx,
                        dy:           _entry.dy,
                        speed:        _entry.speed,
                        duration:     _entry.movement_duration,
                        timer:        0,
                        started:      false,
                        fade_out:     _entry[$ "fade_out"] ?? false,
                        fade_speed:   _entry[$ "fade_speed"] ?? 0.05,
                        fading:       false,
                        ease:         _entry[$ "ease"] ?? "none"
                    });
                }
                else
                {
                    _entry.obj.sprite_index = _entry.sprite;
                    _entry.obj.image_index = 0;
                    _entry.obj.image_speed = _entry.loop ? 1 : 0; 
                    _entry.obj.anim_loop = _entry.loop;
                }
    
                if variable_struct_exists(_entry, "snd") && _entry.snd != noone
                {
                    audio_play_sound(_entry.snd, 1, false, _entry.snd_gain);
                }
            }
            array_delete(after_textbox_delayed_queue, i, 1);
        }
    }
    if array_length(after_textbox_delayed_queue) == 0
    {
        after_queue_armed = false;
    }
}

// 5. TENNA BATTLE INTRO STATE MACHINE
if tenna_battle_intro_state == 1 && instance_exists(obj_tenna)
{
    if obj_tenna.image_speed == 0
    {
        audio_stop_all();
        blackbox_sound_asset = noone;
        blackbox_sound = noone;
        
        obj_tenna.sprite_index = spr_tenna_snap;
        obj_tenna.image_speed = 1;
        obj_tenna.image_index = 0;
        obj_tenna.anim_loop = false;
        
        if instance_exists(obj_kris)
        {
            obj_kris.sprite_index = spr_kris_battle_intro;
            obj_kris.image_speed = 1;
            obj_kris.image_index = 0;
            obj_kris.anim_loop = false;
        }
        if instance_exists(obj_susie)
        {
            obj_susie.sprite_index = spr_susie_battle_intro;
            obj_susie.image_speed = 1;
            obj_susie.image_index = 0;
            obj_susie.anim_loop = false;
        }
        if instance_exists(obj_ralsei)
        {
            obj_ralsei.sprite_index = spr_ralsei_battle_intro;
            obj_ralsei.image_speed = 1;
            obj_ralsei.image_index = 0;
            obj_ralsei.anim_loop = false;
        }
        audio_play_sound(snd_slash, 1, false);
        tenna_battle_intro_state = 1.5;
    }
}

if tenna_battle_intro_state == 1.5
{
    if instance_exists(obj_kris) && obj_kris.image_speed == 0
    {
        tenna_battle_intro_delay = 60;
        tenna_battle_intro_state = 2;
    }
}

if tenna_battle_intro_state == 2
{
    tenna_battle_intro_delay -= 1;
    if tenna_battle_intro_delay <= 0
    {
        tenna_battle_intro_state = 3;
    }
}

if tenna_battle_intro_state == 3
{
    if instance_exists(obj_kris)
    {
        obj_kris.battle_started = true;
        obj_kris.sprite_index = spr_kris_battle_idle;
        obj_kris.image_speed = 1;
        obj_kris.image_index = 0;
        obj_kris.anim_loop = true;
        obj_kris.alarm[3] = 1;
    }
    if instance_exists(obj_susie)
    {
        obj_susie.sprite_index = spr_susie_battle_idle;
        obj_susie.image_speed = 1;
        obj_susie.image_index = 0;
        obj_susie.anim_loop = true;
    }
    if instance_exists(obj_ralsei)
    {
        obj_ralsei.sprite_index = spr_ralsei_battle_idle;
        obj_ralsei.image_speed = 1;
        obj_ralsei.image_index = 0;
        obj_ralsei.anim_loop = true;
    }
    if instance_exists(obj_tenna)
    {
        obj_tenna.use_battle_ext = true;
    }
    tenna_battle_intro_state = 0;
}
// 5b. SUSIE/RALSEI BATTLE INTRO STATE MACHINE (King fight start)
if sr_battle_intro_state == 1
{
    if instance_exists(obj_susie)
    {
        obj_susie.sprite_index = spr_susie_battle_intro;
        obj_susie.image_speed = 1;
        obj_susie.image_index = 0;
        obj_susie.anim_loop = false;
    }
    if instance_exists(obj_ralsei)
    {
        obj_ralsei.sprite_index = spr_ralsei_battle_intro;
        obj_ralsei.image_speed = 1;
        obj_ralsei.image_index = 0;
        obj_ralsei.anim_loop = false;
    }
    audio_play_sound(snd_taking_out_sword, 1, false);
    sr_battle_intro_state = 1.5;
}

if sr_battle_intro_state == 1.5
{
    var _susie_done = !instance_exists(obj_susie) || obj_susie.image_speed == 0;
    var _ralsei_done = !instance_exists(obj_ralsei) || obj_ralsei.image_speed == 0;
    if _susie_done && _ralsei_done
    {
        sr_battle_intro_delay = 15;
        sr_battle_intro_state = 2;
    }
}

if sr_battle_intro_state == 2
{
    sr_battle_intro_delay -= 1;
    if sr_battle_intro_delay <= 0
    {
        sr_battle_intro_state = 3;
    }
}

if sr_battle_intro_state == 3
{
	with (obj_UI) instance_destroy();
	
    if instance_exists(obj_susie)
    {
        obj_susie.sprite_index = spr_susie_battle_idle;
        obj_susie.image_speed = 1;
        obj_susie.image_index = 0;
        obj_susie.anim_loop = true;
    }
    if instance_exists(obj_ralsei)
    {
        obj_ralsei.sprite_index = spr_ralsei_battle_idle;
        obj_ralsei.image_speed = 1;
        obj_ralsei.image_index = 0;
        obj_ralsei.anim_loop = true;
    }
	if instance_exists(obj_king) && obj_king.sprite_index == spr_king_laugh
	{
		obj_king.sprite_index = spr_king_battle_idle;
	}
    // battle start: UI in + music, right as the intro settles
    instance_create_depth(0, 0, -100, obj_UI); // was -20000
    start_battle_music();

	scr_party_init([
    {
        name: "Susie", hp: 290, max_hp: 290, body: obj_susie, body_hurt_sprite: spr_susie_hurt,
        box_offset_x: -1, box_offset_y: -1,
        sprite_frame: spr_susiebox_empty, hurt_frame: spr_susiebox_hurtempty,
        frame_scale: 43 / 156, divider_y: 156,
        bar_offset_x: 516, bar_offset_y: 88, bar_width: 304, bar_height: 36,
        bar_fill_color: make_color_rgb(255, 0, 255),
        hp_current_x: 642, hp_max_x: 701, hp_text_offset_y: 36,
        hurt_flash_time: 20,
		attack_frame: spr_susiebox_attack_empty,
        icon_rect_x: 51, icon_rect_y: 36, icon_rect_w: 147, icon_rect_h: 102, hurt_icon_scale: 1
    },
    {
        name: "Ralsei", hp: 210, max_hp: 210, body: obj_ralsei, body_hurt_sprite: spr_ralsei_shocked,
        box_offset_x: 236, box_offset_y: 0,
        sprite_frame: spr_ralseibox_empty, hurt_frame: spr_ralseibox_hurtempty,
        frame_scale: 42 / 153, divider_y: 153,
        bar_offset_x: 513, bar_offset_y: 85, bar_width: 304, bar_height: 36,
        bar_fill_color: make_color_rgb(1, 255, 0),
        hp_current_x: 639, hp_max_x: 698, hp_text_offset_y: 33,
        hurt_flash_time: 20,
		attack_frame: spr_ralseibox_attack_empty,
        icon_rect_x: 36, icon_rect_y: 21, icon_rect_w: 137, icon_rect_h: 101, hurt_icon_scale: 0.95
    },
    {
        name: "Queen", hp: 1510, max_hp: 1510, body: obj_queen, body_hurt_sprite: spr_queen_shocked,
        box_offset_x: 460, box_offset_y: -10,
        sprite_frame: spr_queenbox_empty, hurt_frame: spr_queenbox_hurtempty,
        frame_scale: 52 / 47, divider_y: 47,
        bar_offset_x: 139, bar_offset_y: 30, bar_width: 76, bar_height: 9,
        bar_fill_color: make_color_rgb(111, 209, 255),
        hp_current_x: 170, hp_max_x: 185, hp_text_offset_y: 17,
        hurt_flash_time: 20,
		attack_frame: spr_queenbox_attack_empty,
        icon_rect_x: 19, icon_rect_y: 16, icon_rect_w: 20, icon_rect_h: 23, hurt_icon_scale: 1
    }
]);

// King's own turn loop — Susie -> Ralsei -> Queen choose attack, attack one at a time,
// dialogue, then (for now) a placeholder gap standing in for King's attack, then repeat.
// Damage numbers and the dialogue_batch below are placeholders — fill in real numbers and
// the next bit of script as it's written.
with (obj_king_turn_sequencer) instance_destroy(); // clear any leftover from a previous fight
var _king_seq = instance_create_depth(0, 0, 0, obj_king_turn_sequencer);
_king_seq.rounds = [
    {
        attackers: [
            { box_name: "Susie",  damage: 115, color_top: make_color_rgb(255, 0, 255), color_bottom: make_color_rgb(255, 0, 255),
              attacker: obj_susie, ready_sprite: spr_susie_attack_ready, attack_sprite: spr_susie_battle_intro, idle_sprite: spr_susie_battle_idle,
              attack_sound: snd_attack },
            { box_name: "Ralsei", damage: 80, color_top: make_color_rgb(1, 255, 0),   color_bottom: make_color_rgb(1, 255, 0),
              attacker: obj_ralsei, ready_sprite: spr_ralsei_attack_ready, attack_sprite: spr_ralsei_attack, idle_sprite: spr_ralsei_battle_idle,
              attack_sound: snd_attack, attack_sound_frame: 4 },
            { box_name: "Queen",  damage: 100, color_top: make_color_rgb(111, 209, 255), color_bottom: make_color_rgb(111, 209, 255),
              attacker: obj_queen, ready_sprite: spr_queen_pie_throw, ready_hold: true, attack_sprite: spr_queen_pie_throw,
              idle_sprite: spr_queen_walk_right_unhappy, idle_hold: true, post_attack_hold_frames: 30,
              attack_sound: snd_attack, attack_sound_frame: 2 }
        ],
        dialogue_batch: [
            { speaker: obj_susie, text: "Lancer didn't deserve anything you did to him." },
            { speaker: obj_susie, text: "You just wanted to be a controlling father and ruin his life." },
            { speaker: obj_king,  text: "Ruin?" },
            { speaker: obj_king,  text: "My son is a prince, with much more value than your friend over here." },
            { speaker: obj_king,  text: "Of course a Lightner would not understand such royalties bestowed." },
            { speaker: obj_queen, text: "We're Not All Lightners Here You Malfunction" },
            { speaker: obj_king,  text: "Oh, I'm sorry. I do not recall addressing you, woman." },
            { speaker: obj_queen, text: "That's Queen To You" },
            { speaker: obj_king,  text: "Then respect your king." }
        ],
		king_box_attack: scr_start_king_attack1
    },
    {
        attackers: [
            { box_name: "Susie",  damage: 115, color_top: make_color_rgb(255, 0, 255), color_bottom: make_color_rgb(255, 0, 255),
              attacker: obj_susie, ready_sprite: spr_susie_attack_ready, attack_sprite: spr_susie_battle_intro, idle_sprite: spr_susie_battle_idle,
              attack_sound: snd_attack },
            { box_name: "Ralsei", damage: 80, color_top: make_color_rgb(1, 255, 0),   color_bottom: make_color_rgb(1, 255, 0),
              attacker: obj_ralsei, ready_sprite: spr_ralsei_attack_ready, attack_sprite: spr_ralsei_attack, idle_sprite: spr_ralsei_battle_idle,
              attack_sound: snd_attack, attack_sound_frame: 4 },
            { box_name: "Queen",  damage: 100, color_top: make_color_rgb(111, 209, 255), color_bottom: make_color_rgb(111, 209, 255),
              attacker: obj_queen, ready_sprite: spr_queen_pie_throw, ready_hold: true, attack_sprite: spr_queen_pie_throw,
              idle_sprite: spr_queen_walk_right_unhappy, idle_hold: true, post_attack_hold_frames: 30,
              attack_sound: snd_attack, attack_sound_frame: 2 }
        ],
        dialogue_batch: [
            { speaker: obj_susie, text: "How'd you even get to be king?" },
            { speaker: obj_susie, text: "With that whole takeover, I'm surprised anyone originally even wanted to be part of your kingdom." },
            { speaker: obj_king,  text: "My people were loyal, Lightner. And they still would be, had you not poisoned their minds." },
            { speaker: obj_susie, text: "That was Lancer, dude. People like him a lot more than they like your sorry leadership." }
        ],
		king_box_attack: scr_start_king_attack2
    },
    {
        attackers: [
            { box_name: "Susie",  damage: 115, color_top: make_color_rgb(255, 0, 255), color_bottom: make_color_rgb(255, 0, 255),
              attacker: obj_susie, ready_sprite: spr_susie_attack_ready, attack_sprite: spr_susie_battle_intro, idle_sprite: spr_susie_battle_idle,
              attack_sound: snd_attack },
            { box_name: "Ralsei", damage: 80, color_top: make_color_rgb(1, 255, 0),   color_bottom: make_color_rgb(1, 255, 0),
              attacker: obj_ralsei, ready_sprite: spr_ralsei_attack_ready, attack_sprite: spr_ralsei_attack, idle_sprite: spr_ralsei_battle_idle,
              attack_sound: snd_attack, attack_sound_frame: 4 },
            { box_name: "Queen",  damage: 100, color_top: make_color_rgb(111, 209, 255), color_bottom: make_color_rgb(111, 209, 255),
              attacker: obj_queen, ready_sprite: spr_queen_pie_throw, ready_hold: true, attack_sprite: spr_queen_pie_throw,
              idle_sprite: spr_queen_walk_right_unhappy, idle_hold: true, post_attack_hold_frames: 30,
              attack_sound: snd_attack, attack_sound_frame: 2 }
        ],
        dialogue_batch: [
            { speaker: obj_king, text: "If you think my leadership was sorry, you should visit the 'other' kings." },
            { speaker: obj_king, text: "They were placed in jail for a reason." },
            { speaker: obj_queen, text: "Yeah Because You're A Corrupt Tyrant" },
            { speaker: obj_king, text: "Save the insults, please. You weren't much better than I was, plugging people into your twisted network of slavery." },
            { speaker: obj_queen, text: "Ok Buddy" },
            { speaker: obj_queen, text: "Just Remember Who Threatened A Child" },
            { speaker: obj_king, text: "You..." }
        ],
		king_box_attack: scr_start_king_attack3
    },
    {
        attackers: [
            { box_name: "Susie",  damage: 115, color_top: make_color_rgb(255, 0, 255), color_bottom: make_color_rgb(255, 0, 255),
              attacker: obj_susie, ready_sprite: spr_susie_attack_ready, attack_sprite: spr_susie_battle_intro, idle_sprite: spr_susie_battle_idle,
              attack_sound: snd_attack },
            { box_name: "Ralsei", damage: 80, color_top: make_color_rgb(1, 255, 0),   color_bottom: make_color_rgb(1, 255, 0),
              attacker: obj_ralsei, ready_sprite: spr_ralsei_attack_ready, attack_sprite: spr_ralsei_attack, idle_sprite: spr_ralsei_battle_idle,
              attack_sound: snd_attack, attack_sound_frame: 4 },
            { box_name: "Queen",  damage: 100, color_top: make_color_rgb(111, 209, 255), color_bottom: make_color_rgb(111, 209, 255),
              attacker: obj_queen, ready_sprite: spr_queen_pie_throw, ready_hold: true, attack_sprite: spr_queen_pie_throw,
              idle_sprite: spr_queen_walk_right_unhappy, idle_hold: true, post_attack_hold_frames: 30,
              attack_sound: snd_attack, attack_sound_frame: 2 }
        ],
        dialogue_batch: [
            { speaker: obj_king, text: "Suffice to say, none of you stand a chance at what's coming." },
            { speaker: obj_susie, text: "Which is..." },
            { speaker: obj_king, text: "Patience, Lightner. Your demise will soon be forgotten." },
            { speaker: obj_susie, text: "Haven't killed me yet, asshole." },
			{ run: function() {
		        obj_queen.sprite_index = spr_queen_walk_right;
				obj_queen.image_speed = 0;
		    } },
            { speaker: obj_queen, text: "You Get Him Girl" },
			{ run: function() {
		        obj_queen.sprite_index = spr_queen_walk_right_unhappy;
				obj_queen.image_speed = 0;
		    } }
        ],
		king_box_attack: scr_start_king_attack4
    },
    {
        attackers: [
            { box_name: "Susie",  damage: 115, color_top: make_color_rgb(255, 0, 255), color_bottom: make_color_rgb(255, 0, 255),
              attacker: obj_susie, ready_sprite: spr_susie_attack_ready, attack_sprite: spr_susie_battle_intro, idle_sprite: spr_susie_battle_idle,
              attack_sound: snd_attack },
            { box_name: "Ralsei", damage: 80, color_top: make_color_rgb(1, 255, 0),   color_bottom: make_color_rgb(1, 255, 0),
              attacker: obj_ralsei, ready_sprite: spr_ralsei_attack_ready, attack_sprite: spr_ralsei_attack, idle_sprite: spr_ralsei_battle_idle,
              attack_sound: snd_attack, attack_sound_frame: 4 },
            { box_name: "Queen",  damage: 100, color_top: make_color_rgb(111, 209, 255), color_bottom: make_color_rgb(111, 209, 255),
              attacker: obj_queen, ready_sprite: spr_queen_pie_throw, ready_hold: true, attack_sprite: spr_queen_pie_throw,
              idle_sprite: spr_queen_walk_right_unhappy, idle_hold: true, post_attack_hold_frames: 30,
              attack_sound: snd_attack, attack_sound_frame: 2 }
        ],
        dialogue_batch: [
            { speaker: obj_king, text: "If you all care so deeply for Lancer, why not embrace my ruling?" },
            { speaker: obj_ralsei, text: "Your ruling has nothing to do with Lancer, and we all know that." },
            { speaker: obj_queen, text: "Although My Calibrations Are Set To: Take Over The World, You Are Not The Right Person To Work With" },
            { speaker: obj_king, text: "Right, because using children to further your gain is so much better than the alternative." },
            { speaker: obj_queen, text: "Holy Hypocrisy Bro" }
        ],
		king_box_attack: scr_start_king_attack5
    },
    {
        attackers: [
            { box_name: "Susie",  damage: 115, color_top: make_color_rgb(255, 0, 255), color_bottom: make_color_rgb(255, 0, 255),
              attacker: obj_susie, ready_sprite: spr_susie_attack_ready, attack_sprite: spr_susie_battle_intro, idle_sprite: spr_susie_battle_idle,
              attack_sound: snd_attack },
            { box_name: "Ralsei", damage: 80, color_top: make_color_rgb(1, 255, 0),   color_bottom: make_color_rgb(1, 255, 0),
              attacker: obj_ralsei, ready_sprite: spr_ralsei_attack_ready, attack_sprite: spr_ralsei_attack, idle_sprite: spr_ralsei_battle_idle,
              attack_sound: snd_attack, attack_sound_frame: 4 },
            { box_name: "Queen",  damage: 100, color_top: make_color_rgb(111, 209, 255), color_bottom: make_color_rgb(111, 209, 255),
              attacker: obj_queen, ready_sprite: spr_queen_pie_throw, ready_hold: true, attack_sprite: spr_queen_pie_throw,
              idle_sprite: spr_queen_walk_right_unhappy, idle_hold: true, post_attack_hold_frames: 30,
              attack_sound: snd_attack, attack_sound_frame: 2 }
        ],
        dialogue_batch: [
            { speaker: obj_king, text: "You seem awfully quiet, Prince." },
            { speaker: obj_king, text: "Cat got your tongue? Or is there something more discreet we should know about?" },
            { speaker: obj_ralsei, text: "You're not gonna get away with it, King. We won't let it happen." },
            { speaker: obj_queen, text: "I'm So Lost" },
            { speaker: obj_susie, text: "What are we talking about???" },
			{ run: function() {
		        obj_susie.sprite_index = spr_susie_battle_idle_lookback;
		    } },
            { speaker: obj_ralsei, text: "King's planning on", instant_cutoff: true },
			{ run: function() {
		        obj_susie.sprite_index = spr_susie_battle_idle;
		    } },
            { speaker: obj_king, text: "Silence, boy." },
            { speaker: obj_king, text: "Wait your turn to spoil the fun." },
            { speaker: obj_ralsei, text: "..." }
        ],
		king_box_attack: scr_start_king_attack6
    },
    {
        attackers: [
            { box_name: "Susie",  damage: 115, color_top: make_color_rgb(255, 0, 255), color_bottom: make_color_rgb(255, 0, 255),
              attacker: obj_susie, ready_sprite: spr_susie_attack_ready, attack_sprite: spr_susie_battle_intro, idle_sprite: spr_susie_battle_idle,
              attack_sound: snd_attack },
            { box_name: "Ralsei", damage: 80, color_top: make_color_rgb(1, 255, 0),   color_bottom: make_color_rgb(1, 255, 0),
              attacker: obj_ralsei, ready_sprite: spr_ralsei_attack_ready, attack_sprite: spr_ralsei_attack, idle_sprite: spr_ralsei_battle_idle,
              attack_sound: snd_attack, attack_sound_frame: 4 },
            { box_name: "Queen",  damage: 100, color_top: make_color_rgb(111, 209, 255), color_bottom: make_color_rgb(111, 209, 255),
              attacker: obj_queen, ready_sprite: spr_queen_pie_throw, ready_hold: true, attack_sprite: spr_queen_pie_throw,
              idle_sprite: spr_queen_walk_right_unhappy, idle_hold: true, post_attack_hold_frames: 30,
              attack_sound: snd_attack, attack_sound_frame: 2 }
        ],
        dialogue_batch: [
            { speaker: obj_susie, text: "This is stupid. You need to get back in your cell." },
            { speaker: obj_king, text: "What, is your impatience getting the better of you, Lightner?" },
            { speaker: obj_king, text: "Enjoy this for what it is." },
            { speaker: obj_susie, text: "And that would be?" },
            { speaker: obj_king, text: "The calm before the storm." }
        ],
		king_box_attack: scr_start_king_attack7
    },
    {
	    attackers: [],
	    // no real attack this round (King cuts himself off) — but the party should still
	    // raise into their battle-ready poses like every other round; scr_king_turn_sequencer
	    // falls back to this list for select-stage poses when attackers is empty, then puts
	    // everyone back to idle the moment Lancer arrives
	    ready_poses: [
	        { attacker: obj_susie,  ready_sprite: spr_susie_attack_ready, idle_sprite: spr_susie_battle_idle },
	        { attacker: obj_ralsei, ready_sprite: spr_ralsei_attack_ready, idle_sprite: spr_ralsei_battle_idle },
	        { attacker: obj_queen,  ready_sprite: spr_queen_pie_throw, ready_hold: true,
	          idle_sprite: spr_queen_walk_right_unhappy, idle_hold: true }
	    ],
	    dialogue_batch: [
	        { speaker: obj_king, text: "Now, to finally meet your" }
	    ],
	    is_final: true
    }
];

    global.fight_seq_starting = false;
    sr_battle_intro_state = 0;
}

// 5c. RALSEI-ONLY "BATTLE" — no readies, no attacks; dialogue plays, then it fades to another room
if ralsei_solo_state == 1
{
    if instance_exists(obj_ralsei)
    {
        with (obj_ralsei)
        {
            // keep his body exactly where it is: line up the visible bottom-center of his
            // current sprite with the body in the battle sprites (battle_idle's bbox, since
            // battle_intro shares its size/origin but its bbox includes the swing)
            var _old = sprite_index;
            var _ref = spr_ralsei_battle_idle;
            var _fx = x + ((sprite_get_bbox_left(_old) + sprite_get_bbox_right(_old) + 1) / 2 - sprite_get_xoffset(_old)) * image_xscale;
            var _fy = y + (sprite_get_bbox_bottom(_old) + 1 - sprite_get_yoffset(_old)) * image_yscale;
            x = _fx - ((sprite_get_bbox_left(_ref) + sprite_get_bbox_right(_ref) + 1) / 2 - sprite_get_xoffset(_ref)) * image_xscale;
            y = _fy - (sprite_get_bbox_bottom(_ref) + 1 - sprite_get_yoffset(_ref)) * image_yscale;

            sprite_index = spr_ralsei_battle_intro;
            last_sprite = sprite_index; // stop scr_auto_keep_feet from re-anchoring this swap
            image_speed = 1;
            image_index = 0;
            anim_loop = false;
        }
    }
    audio_play_sound(snd_taking_out_sword, 1, false);
    ralsei_solo_state = 1.5;
}

if ralsei_solo_state == 1.5
{
    if (!instance_exists(obj_ralsei) || obj_ralsei.image_speed == 0)
    {
        ralsei_solo_delay = 15;
        ralsei_solo_state = 2;
    }
}

if ralsei_solo_state == 2
{
    ralsei_solo_delay -= 1;
    if ralsei_solo_delay <= 0
    {
        ralsei_solo_state = 3;
    }
}

if ralsei_solo_state == 3
{
    with (obj_UI) instance_destroy();

    if instance_exists(obj_ralsei)
    {
        with (obj_ralsei)
        {
            sprite_index = spr_ralsei_battle_idle; // same size/origin as battle_intro, no move needed
            last_sprite = sprite_index;
            image_speed = 1;
            image_index = 0;
            anim_loop = true;
        }
    }

    start_battle_music();
    scr_ralsei_solo_ui_setup(false);
	
    with (obj_king_turn_sequencer) instance_destroy();
    var _seq = instance_create_depth(0, 0, 0, obj_king_turn_sequencer);
    _seq.dialogue_only = true;
    _seq.on_end_warp = function() { scr_ralsei_battle_snapshot(); }; // remember the battle so we can come back to it
    _seq.end_warp_room = rm_two;      // <- room to fade into, swap for the real one
    _seq.end_warp_song = noone;       // <- music for the other side (noone = silence)
	_seq.end_warp_wait = 240; // frames held on black before the next room loads
    var _rk_cps = 0.15; // slower than default_cps (0.4), like his scr_text_slow lines
    _seq.rounds = [
        {
            attackers: [],
            dialogue_batch: [
                { speaker: obj_king,   text: "A battle? Without anyone on your side?" },
                { speaker: obj_king,   text: "I sense it will be mildly difficult to obtain victory here, Prince." },
                { speaker: obj_ralsei, text: "I don't need to fight you." },
                { speaker: obj_king,   text: "Hm?" },
                { speaker: obj_ralsei, text: "As long as I hold my turn, the battle won't progress." },
                { speaker: obj_ralsei, text: "You guys will be stuck here until I choose an action." },
                { speaker: obj_king,   text: "..." },
                { speaker: obj_king,   text: "Is this true, my Knight?" },
                { speaker: obj_knight, text: "...",      cps: _rk_cps },
                { speaker: obj_knight, text: "Yes...",   cps: _rk_cps, snd: snd_knight_phone_call },
                { speaker: obj_king,   text: "How did you learn this tactic, Prince?" },
                { speaker: obj_ralsei, text: "Saw a flower do it." },
                { speaker: obj_knight, text: "...",      cps: _rk_cps }
            ]
        }
    ];

    global.fight_seq_starting = false;
    ralsei_solo_state = 0;
}

// 6. IMPACT SEQUENCE STATE MACHINE
if impact_seq_state == 1
{
    audio_play_sound(snd_impact, 1, false);
    impact_seq_timer = game_get_speed(gamespeed_fps);
    impact_seq_state = 2;
}
if impact_seq_state == 2
{
    impact_seq_timer -= 1;
    if impact_seq_timer <= 0
    {
        audio_play_sound(snd_impact, 1, false);
        impact_seq_timer = game_get_speed(gamespeed_fps);
        impact_seq_state = 3;
    }
}
if impact_seq_state == 3
{
    impact_seq_timer -= 1;
    if impact_seq_timer <= 0
    {
        audio_play_sound(snd_explosion, 1, false);
        scr_roark_ball_start();
        impact_seq_state = 0;
    }
}

// 7. VILLAINS ASCENDING LOGIC
if villains_ascending
{
    if instance_exists(obj_jevil)
    {
        obj_jevil.y -= 0.5;
        obj_jevil.image_alpha -= 0.01;
        if obj_jevil.image_alpha <= 0
        {
            obj_jevil.image_alpha = 0;
            instance_destroy(obj_jevil);
        }
    }
    if instance_exists(obj_spamton)
    {
        obj_spamton.y -= 0.5;
        obj_spamton.image_alpha -= 0.01;
        if obj_spamton.image_alpha <= 0
        {
            obj_spamton.image_alpha = 0;
            instance_destroy(obj_spamton);
        }
    }
    if !instance_exists(obj_jevil) && !instance_exists(obj_spamton)
    {
        villains_ascending = false;
    }
}

// 7. VILLAINS DESCENDING LOGIC
if (villains_descending)
{
    var _all_done = true;

    // --- Handle Jevil ---
    if (instance_exists(obj_jevil))
    {
        if (obj_jevil.y < obj_jevil.target_y || obj_jevil.image_alpha < 1)
        {
            obj_jevil.y += 2;
            obj_jevil.image_alpha += 0.03;
            _all_done = false;
        }
        else
        {
            with (obj_jevil)
            {
                y = target_y;
                x = target_x;
                in_cutscene = false;
                start_y = y;
                image_alpha = 1;
                sprite_index = spr_jevil_left;
                image_speed = 0; 
                image_index = 0; 
            }
        }
    }

    // --- Handle Spamton ---
    if (instance_exists(obj_spamton))
    {
        if (obj_spamton.y < obj_spamton.target_y)
        {
            obj_spamton.y += 2;
            obj_spamton.image_alpha += 0.03;
            _all_done = false;
        }
        else
        {
            obj_spamton.y = obj_spamton.target_y;
            obj_spamton.x = obj_spamton.target_x;
            obj_spamton.image_alpha = 1;
            obj_spamton.sprite_index = spr_spamton_left;
            obj_spamton.image_speed = 0;
        }
    }

    // --- Cleanup ---
    if (_all_done)
    {
        villains_descending = false;
    }
}

// 8. ACTIVE CHARACTER MOVEMENT LOGIC
for (var i = array_length(move_queue_active) - 1; i >= 0; i--)
{
    var _m = move_queue_active[i];
    if instance_exists(_m.obj)
    {
        if (!_m.started)
        {
            _m.obj.sprite_index = _m.sprite;
            _m.obj.image_index = 0;
            _m.obj.image_speed = _m.loop ? 1 : 0;
            _m.obj.anim_loop = _m.loop;
            _m.started = true;
        }

                if (!_m.fading)
        {
            var _ease = _m[$ "ease"] ?? "none";

            if (_ease != "none")
            {
                // EASED MOVE: lerp from start to end over the duration
                if (!variable_struct_exists(_m, "sx"))
                {
                    _m.sx = _m.obj.x;
                    _m.sy = _m.obj.y;
                    _m.tx = _m.sx + _m.dx * _m.speed * _m.duration;
                    _m.ty = _m.sy + _m.dy * _m.speed * _m.duration;
                }

                _m.timer++;
                var _k = (_m.duration > 0) ? scr_ease(_m.timer / _m.duration, _ease) : 1;

                // round so pixel-art sprites don't smear on sub-pixels
                _m.obj.x = round(lerp(_m.sx, _m.tx, _k));
                _m.obj.y = round(lerp(_m.sy, _m.ty, _k));
            }
            else
            {
                if (!variable_struct_exists(_m, "x_acc")) _m.x_acc = 0;
                if (!variable_struct_exists(_m, "y_acc")) _m.y_acc = 0;

                _m.x_acc += (_m.dx * _m.speed);
                _m.y_acc += (_m.dy * _m.speed);

                var _hit_wall = false;

                with (_m.obj)
                {
                    while (abs(_m.x_acc) >= 1)
                    {
                        var _dir = sign(_m.x_acc);
                        if (!place_meeting(x + _dir, y, obj_wall))
                        {
                            x += _dir;
                            _m.x_acc -= _dir;
                        }
                        else
                        {
                            _hit_wall = true;
                            _m.x_acc = 0;
                            break;
                        }
                    }

                    while (abs(_m.y_acc) >= 1)
                    {
                        var _dir = sign(_m.y_acc);
                        if (!place_meeting(x, y + _dir, obj_wall))
                        {
                            y += _dir;
                            _m.y_acc -= _dir;
                        }
                        else
                        {
                            _hit_wall = true;
                            _m.y_acc = 0;
                            break;
                        }
                    }
                }

                _m.timer++;

                if (_hit_wall)
                {
                    _m.timer = _m.duration;
                }
            }
        }
        else
        {
            _m.obj.image_alpha -= _m.fade_speed;
            if (_m.obj.image_alpha <= 0)
            {
                instance_destroy(_m.obj);
                array_delete(move_queue_active, i, 1);
                continue;
            }
        }
        
        if (!_m.fading && _m.timer >= _m.duration)
        {
            if (_m.fade_out)
            {
                _m.fading = true;
            }
            else
            {
                var _has_next_move = false;
                for (var j = 0; j < array_length(move_queue_active); j++)
                {
                    if (j != i && move_queue_active[j].obj == _m.obj)
                    {
                        _has_next_move = true;
                        break;
                    }
                }
                if (!_has_next_move)
                {
                    for (var j = 0; j < array_length(after_textbox_delayed_queue); j++)
                    {
                        var _dq = after_textbox_delayed_queue[j];
                        if (variable_struct_exists(_dq, "obj") && _dq.obj == _m.obj && variable_struct_exists(_dq, "is_movement") && _dq.is_movement)
                        {
                            _has_next_move = true;
                            break;
                        }
                    }
                }

                if (!_has_next_move)
                {
                    _m.obj.image_index = 0;
                    _m.obj.image_speed = 0;
                }
                
                array_delete(move_queue_active, i, 1);
            }
        }
    }
    else
    {
        array_delete(move_queue_active, i, 1);
    }
}

// 8b. ORDERED MOVEMENT GROUP QUEUE
if (!current_movement_group_active && array_length(movement_queue) > 0)
{
    var _group = movement_queue[0];
    array_delete(movement_queue, 0, 1);

    for (var i = 0; i < array_length(_group.moves); i++)
    {
        var _mv = _group.moves[i];
        array_push(move_queue_active, {
            obj: _mv.obj,
            sprite: _mv.sprite,
            loop: _mv.loop,
            dx: _mv.dx,
            dy: _mv.dy,
            speed: _mv.speed,
            duration: variable_struct_exists(_mv, "duration") ? _mv.duration : 0,
            timer: 0,
            started: false,
            fade_out: variable_struct_exists(_mv, "fade_out") ? _mv.fade_out : false,
            fade_speed: variable_struct_exists(_mv, "fade_speed") ? _mv.fade_speed : 0.05,
            fading: false,
			ease: _mv[$ "ease"] ?? "none"
        });
    }

    current_movement_group_active = true;
}

if (current_movement_group_active && array_length(move_queue_active) == 0)
{
    current_movement_group_active = false; // clear to start the next group
}

// IMPACT FLASH STATE MACHINE
if (impact_flash_state == 1) // darken to full black
{
    impact_flash_darken_alpha += impact_flash_darken_speed;
    if (impact_flash_darken_alpha >= impact_flash_darken_target)
    {
        impact_flash_darken_alpha = impact_flash_darken_target;
        impact_flash_state = 2;
    }
}

if (impact_flash_state == 2) // wait, then fade circle in
{
    impact_flash_wait_timer -= 1;
    var _fade_start = impact_flash_wait_duration / 2;
    if (impact_flash_wait_timer <= _fade_start)
    {
        impact_flash_circle_alpha = clamp(1 - (impact_flash_wait_timer / _fade_start), 0, 1);
    }
    if (impact_flash_wait_timer <= 0)
    {
        impact_flash_circle_alpha = 1;
        impact_flash_state = 3;
    }
}

if (impact_flash_state == 3) // circle rushes toward target
{
    impact_flash_circle_angle = point_direction(impact_flash_circle_x, impact_flash_circle_y, impact_flash_target.x, impact_flash_target.y);
    var _dist = point_distance(impact_flash_circle_x, impact_flash_circle_y, impact_flash_target.x, impact_flash_target.y);

    if (_dist <= impact_flash_circle_speed)
    {
        impact_flash_circle_x = impact_flash_target.x;
        impact_flash_circle_y = impact_flash_target.y;
        impact_flash_state = 4;

		audio_play_sound(snd_impact, 1, false);

        if (impact_flash_hit_sprite != noone)
        {
            with (impact_flash_target)
            {
                sprite_index = other.impact_flash_hit_sprite;
                image_index = 0;
                image_speed = 0;
            }
            impact_flash_freeze_timer = impact_flash_freeze_duration;
        }
        else
        {
            impact_flash_freeze_timer = 0; // no freeze frame, skip straight through
        }
    }
    else
    {
        impact_flash_circle_x += lengthdir_x(impact_flash_circle_speed, impact_flash_circle_angle);
        impact_flash_circle_y += lengthdir_y(impact_flash_circle_speed, impact_flash_circle_angle);
    }
}

if (impact_flash_state == 4) // freeze frame (if any), screen fading back in
{
    impact_flash_darken_alpha -= impact_flash_darken_speed * 2;
    if (impact_flash_darken_alpha < 0) impact_flash_darken_alpha = 0;

    impact_flash_freeze_timer -= 1;
    if (impact_flash_freeze_timer <= 0)
	{
		if (impact_flash_spawn_obj != noone)
		{
		    var _old_target = impact_flash_target;
		    mewmew_before_impact_inst = _old_target; // <-- dedicated reference to the ORIGINAL

		    if (impact_flash_original_sprite != noone)
		    {
		        _old_target.sprite_index = impact_flash_original_sprite;
		        _old_target.image_index = 0;
		        _old_target.image_speed = 0;
		    }

		    var _new_inst = instance_create_depth(_old_target.x, _old_target.y, _old_target.depth, impact_flash_spawn_obj);
		    _new_inst.image_xscale = _old_target.image_xscale;
		    _new_inst.image_yscale = _old_target.image_yscale;
		    _new_inst.image_speed = 0;
		    if (impact_flash_yelling_sprite != noone)
		    {
		        _new_inst.sprite_index = impact_flash_yelling_sprite;
		        _new_inst.image_index = 0;
		    }

		    impact_flash_target = _new_inst;
		    mewmew_after_impact_inst = _new_inst;
		}
	    else if (impact_flash_yelling_sprite != noone)
	    {
	        with (impact_flash_target)
	        {
	            sprite_index = other.impact_flash_yelling_sprite;
	            image_index = 0;
	            image_speed = 0;
	        }
	    }
	    impact_flash_state = 5;
	}
}

if (impact_flash_state == 5) // knockback + gerson reacting, screen continues fading in
{
    impact_flash_darken_alpha -= impact_flash_darken_speed * 2;
    if (impact_flash_darken_alpha < 0) impact_flash_darken_alpha = 0;

    with (impact_flash_target)
    {
        x += lengthdir_x(other.impact_flash_knockback_speed, other.impact_flash_knockback_dir);
        y += lengthdir_y(other.impact_flash_knockback_speed, other.impact_flash_knockback_dir);
    }
    impact_flash_knockback_speed -= impact_flash_knockback_friction;
    if (impact_flash_knockback_speed < 0) impact_flash_knockback_speed = 0;

    if (impact_flash_gerson_obj != noone && instance_exists(impact_flash_gerson_obj) && impact_flash_gerson_speed > 0)
    {
        with (impact_flash_gerson_obj)
        {
            x += lengthdir_x(other.impact_flash_gerson_speed, other.impact_flash_gerson_dir);
            y += lengthdir_y(other.impact_flash_gerson_speed, other.impact_flash_gerson_dir);
        }
        impact_flash_gerson_speed -= impact_flash_gerson_friction;
        if (impact_flash_gerson_speed < 0) impact_flash_gerson_speed = 0;
    }

    if (impact_flash_knockback_speed <= 0)
    {
        impact_flash_state = 6;
        impact_flash_waiting = true;
    }
}

if (impact_flash_state == 6 && impact_flash_waiting) // wait for continue
{
    if (keyboard_check_pressed(ord("Z")))
    {
        impact_flash_state = 0;
        impact_flash_waiting = false;
        impact_flash_darken_alpha = 0;

        if (impact_flash_next_text_id != noone)
        {
            create_textbox(impact_flash_next_text_id);
        }
    }
}

// GATEKEEPER:
if (waiting_for_warp && array_length(move_queue_active) == 0)
{
    if instance_exists(obj_textbox) {instance_destroy(obj_textbox)}
    
    if (!instance_exists(obj_cutscenefade))
    {
        var _fader = instance_create_depth(0, 0, -9999, obj_cutscenefade);
        _fader.fade_target = 1;
        
        // Just set the target, the fader handles the rest
        if (warp_step == 0) { _fader.target_room = rm_two; warp_step = 1; }
        else if (warp_step == 1) { _fader.target_room = rm_one; warp_step = 2; }
		else if (warp_step == 2) { _fader.target_room = rm_four; warp_step = 3; }
		else if (warp_step == 3) { _fader.target_room = rm_five; warp_step = 4; }
    }
    waiting_for_warp = false;
}

// ON-PAGE MOVEMENT (stops naturally on duration end, OR immediately if page changes/cutoff skips ahead)
for (var i = array_length(page_move_active) - 1; i >= 0; i--)
{
    var _m = page_move_active[i];

    if (!instance_exists(obj_textbox) || obj_textbox.page != _m.page)
    {
        // page changed (normal advance OR cutoff-skip) or textbox closed — stop immediately
        if (instance_exists(_m.obj))
        {
            _m.obj.image_speed = 0;
        }
        array_delete(page_move_active, i, 1);
        continue;
    }

        if (instance_exists(_m.obj))
    {
        var _ease = _m[$ "ease"] ?? "none";

        if (_ease != "none")
        {
            if (!variable_struct_exists(_m, "sx"))
            {
                _m.sx = _m.obj.x;
                _m.sy = _m.obj.y;
                _m.tx = _m.sx + _m.dx * _m.speed * _m.duration;
                _m.ty = _m.sy + _m.dy * _m.speed * _m.duration;
            }

            _m.timer++;
            var _k = (_m.duration > 0) ? scr_ease(_m.timer / _m.duration, _ease) : 1;
            _m.obj.x = round(lerp(_m.sx, _m.tx, _k));
            _m.obj.y = round(lerp(_m.sy, _m.ty, _k));
        }
        else
        {
            _m.obj.x += _m.dx * _m.speed;
            _m.obj.y += _m.dy * _m.speed;
            _m.timer++;
        }

        if (_m.timer >= _m.duration)
        {
            _m.obj.image_speed = 0;
            array_delete(page_move_active, i, 1);
        }
    }
    else
    {
        array_delete(page_move_active, i, 1);
    }
}

// N. GENERIC FADE-IN HANDLING
with (all)
{
    if (variable_instance_exists(id, "fading_in") && fading_in)
    {
        image_alpha += fade_in_speed;
        if (image_alpha >= 1)
        {
            image_alpha = 1;
            fading_in = false;
        }
    }
}

// Debug Party Damage
if (keyboard_check_pressed(vk_f1))
{
    scr_party_damage(10);
}

if (keyboard_check_pressed(vk_f2))
{
    with (obj_UI) instance_destroy(); // clear any leftover UI before testing
    instance_create_depth(0, 0, -100, obj_UI);

    scr_party_init([
    {
        name: "Susie", hp: 290, max_hp: 290, body: obj_susie, body_hurt_sprite: spr_susie_hurt,
        box_offset_x: -1, box_offset_y: -1,
        sprite_frame: spr_susiebox_empty, hurt_frame: spr_susiebox_hurtempty,
        frame_scale: 43 / 156, divider_y: 156,
        bar_offset_x: 516, bar_offset_y: 88, bar_width: 304, bar_height: 36,
        bar_fill_color: make_color_rgb(255, 0, 255),
        hp_current_x: 642, hp_max_x: 701, hp_text_offset_y: 36,
        hurt_flash_time: 20,
		attack_frame: spr_susiebox_attack_empty,
        icon_rect_x: 51, icon_rect_y: 36, icon_rect_w: 147, icon_rect_h: 102, hurt_icon_scale: .9
    },
    {
        name: "Ralsei", hp: 210, max_hp: 210, body: obj_ralsei, body_hurt_sprite: spr_ralsei_shocked,
        box_offset_x: 236, box_offset_y: 0,
        sprite_frame: spr_ralseibox_empty, hurt_frame: spr_ralseibox_hurtempty,
        frame_scale: 42 / 153, divider_y: 153,
        bar_offset_x: 513, bar_offset_y: 85, bar_width: 304, bar_height: 36,
        bar_fill_color: make_color_rgb(1, 255, 0),
        hp_current_x: 639, hp_max_x: 698, hp_text_offset_y: 33,
        hurt_flash_time: 20,
		attack_frame: spr_ralseibox_attack_empty,
        icon_rect_x: 36, icon_rect_y: 21, icon_rect_w: 137, icon_rect_h: 101, hurt_icon_scale: 0.95
    },
    {
        name: "Queen", hp: 1510, max_hp: 1510, body: obj_queen, body_hurt_sprite: spr_queen_shocked,
        box_offset_x: 460, box_offset_y: -10,
        sprite_frame: spr_queenbox_empty, hurt_frame: spr_queenbox_hurtempty,
        frame_scale: 52 / 47, divider_y: 47,
        bar_offset_x: 139, bar_offset_y: 30, bar_width: 76, bar_height: 9,
        bar_fill_color: make_color_rgb(111, 209, 255),
        hp_current_x: 170, hp_max_x: 185, hp_text_offset_y: 17,
        hurt_flash_time: 20,
		attack_frame: spr_queenbox_attack_empty,
        icon_rect_x: 19, icon_rect_y: 16, icon_rect_w: 20, icon_rect_h: 23, hurt_icon_scale: 1
    }
	]);
}

if (keyboard_check_pressed(vk_f3))
{
    var _members = []; // gather living boxes in party order
    with (obj_battle_ui_box) array_push(_members, id);

    if (array_length(_members) > 0)
    {
        var _current_i = 0;
        for (var i = 0; i < array_length(_members); i++)
        {
            if (_members[i] == obj_UI.active_box) { _current_i = i; break; }
        }
        var _next_i = (_current_i + 1) mod array_length(_members);
        obj_UI.active_box = _members[_next_i];
    }
}