function scr_ui_sequence(_steps, _callback = noone)
{
    global.ui_sequence_active = true;
    global.ui_seq_steps = _steps;
    global.ui_seq_index = 0;
    global.ui_seq_callback = _callback;
    scr_ui_sequence_next();
}

function scr_ui_sequence_next()
{
    show_debug_message("ui_seq_next called — index: " + string(global.ui_seq_index) + " / " + string(array_length(global.ui_seq_steps)));

    if (global.ui_seq_index >= array_length(global.ui_seq_steps))
	{
	    global.ui_sequence_active = false;
	    if (global.ui_seq_callback != noone)
	    {
	        var _cb = global.ui_seq_callback;
	        global.ui_seq_callback = noone;
	        _cb();
	    }
	    return;
	}

    var _step = global.ui_seq_steps[global.ui_seq_index];
    global.ui_seq_index++;

    show_debug_message("setting UI sprite to: " + sprite_get_name(_step.sprite) + " | obj_UI count: " + string(instance_number(obj_UI)));

    if (instance_exists(obj_UI))
    {
        obj_UI.sprite_index = _step.sprite;
        obj_UI.image_index = 0;
    }

    if (variable_struct_exists(_step, "snd") && _step.snd != noone)
    {
        audio_play_sound(_step.snd, 5, false);
    }

    var _delay = variable_struct_exists(_step, "delay") ? _step.delay : 20;
    scr_call_after_frames(scr_ui_sequence_next, _delay);
}

function scr_fight_seq_ui_done_flag()
{
    global.fight_seq_ui_done = true;
}