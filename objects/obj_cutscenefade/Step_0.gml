if (fade_target == 1)
{
    if (!old_music_faded && global.music != noone)
	{
	    old_music_inst = global.music;
	    audio_sound_gain(global.music, 0, old_music_fade_time);
	    old_music_faded = true;
	}

    if (fade_alpha < 1)
    {
        fade_alpha += fade_step;
    }
    else
    {
        if (wait_timer < wait_duration)
        {
            wait_timer++;
        }
        else
        {
            // NEW: Check if we are staying in the same room or changing rooms
            if (fade_back_same_room)
			{
			    if (hold_black)
			    {
			        // Stay completely black until another piece of code
			        // explicitly sets fade_target = 0.
			        fade_alpha = 1;
			    }
			    else if (flash_wait_timer < flash_wait_duration)
			    {
			        flash_wait_timer++;
			    }
			    else
			    {
			        fade_target = 0;
			    }
			}
            else
            {
                // Original behavior: change rooms
               if (room != target_room)
				{
				    // old track is silent by now, actually stop it
				    if (old_music_inst != noone)
				    {
				        audio_stop_sound(old_music_inst);
				        old_music_inst = noone;
				    }
				    room_goto(target_room);
				}
                else 
                {
                    // NEW: Once we are successfully in the target room, start fading in!
                    fade_target = 0;
                }
            }
        }
    }
}
else if (fade_target == 0)
{
	if (!has_spawned)
     {
         for (var i = 0; i < array_length(spawn_list); i++)
         {
            var _s = spawn_list[i];
            var _inst = instance_create_layer(_s.x, _s.y, _s.layer, _s.obj);
            if (variable_struct_exists(_s, "setup") && _s.setup != noone && is_method(_s.setup))
            {
                _s.setup(_inst);
             }
         }
         has_spawned = true;
    }
    // (Keep your existing fade-out-to-transparent code here)
    if (!music_started && new_music_sound != noone)
    {
        global.music = audio_play_sound(new_music_sound, 1, true, 0);
        audio_sound_gain(global.music, new_music_gain, new_music_fade_time);
        global.song = new_music_sound;
        global.song_start = current_time;
        music_started = true;
    }

    if (music_lead_timer < music_lead_frames)
    {
        music_lead_timer++; 
    }
    else
    {
        if (fade_alpha > 0)
        {
            fade_alpha -= fade_step;
        }
        else
        {
            instance_destroy();
        }
    }
}