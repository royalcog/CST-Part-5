var _step = (step_index >= 0 && step_index < array_length(sequence)) ? sequence[step_index] : noone;

switch (state)
{
    case "advance":
        step_index++;
        if (step_index >= array_length(sequence))
        {
            state = "finished";
            break;
        }
        _step = sequence[step_index];
        
        if (_step.type == "talk")
        {
            var _chain = instance_create_depth(0, 0, 0, obj_dialogue_chain);
            _chain.batches = [ _step.batch ];
            state = "waiting_talk";
        }
        else if (_step.type == "attack")
		{
		    pre_attack_ui_sprite = instance_exists(obj_UI) ? obj_UI.sprite_index : spr_UI_Pink;

		    scr_ui_hide();
		    global.fight_attack_active = true;

		    if (instance_exists(obj_friend)) { obj_friend.visible = false; }
		    with (obj_fist_slam_cutscene) { visible = false; }

		    box_inst = scr_spawn_battlebox();
		    state = "waiting_box_open";
		}
        else if (_step.type == "sprite")
		{
		    var _target = _step.target;
		    var _new_spr = _step.new_sprite;

		    with (_target)
		    {
		        sprite_index = _new_spr;
		        image_index = 0;
		        image_speed = 1; // reset in case it was frozen by a previous TALKbox line
		    }

		    state = "advance";
		}
		else if (_step.type == "ui_sequence")
		{
		    global.fight_seq_ui_done = false;
		    scr_ui_sequence(_step.steps, scr_fight_seq_ui_done_flag);
		    state = "waiting_ui_sequence";
		}
		else if (_step.type == "barrage")
		{
		    var _s = instance_create_depth(0, 0, 0, obj_barrage_spawner);
		    _s.data = _step.data;
		    state = "waiting_barrage";
		}
		else if (_step.type == "fist_slam")
		{
		    var _f = instance_create_depth(0, 0, 0, obj_fist_slam_cutscene);
		    _f.target_inst = _step.target;
		    if (variable_struct_exists(_step, "fist_sprite")) _f.fist_sprite = _step.fist_sprite;
		    if (variable_struct_exists(_step, "spawn_side"))  _f.spawn_side  = _step.spawn_side;
		    state = "waiting_fist_slam";
		}
		else if (_step.type == "fist_split")
		{
		    var _move = variable_struct_exists(_step, "move_right") ? _step.move_right : 30;
		    scr_fist_slam_split(_step.target, _move);
		    state = "advance";
		}
		// runs an arbitrary standalone cutscene object with no battlebox involved
		// (unlike "attack", which always opens a box first) — used for things
		// like the finale sword-hit cutscene, which needs Friend visible/on-screen
		else if (_step.type == "custom_cutscene")
		{
		    custom_inst = _step.start_func();
		    state = "waiting_custom_cutscene";
		}
    break;

	case "waiting_ui_sequence":
	    if (global.fight_seq_ui_done)
	    {
	        state = "advance";
	    }
	break;

    case "waiting_talk":
        if (!instance_exists(obj_dialogue_chain))
        {
            state = "advance";
        }
    break;

    case "waiting_box_open":
    if (instance_exists(box_inst) && box_inst.state == "idle")
	    {
	        if (variable_struct_exists(_step, "kind") && _step.kind == "custom")
	        {
	            custom_inst = _step.start_func();
	            state = "waiting_custom_attack";
	        }
	        else
	        {
	            scr_start_attack(_step.attacker, _step.data);
	            state = "waiting_attack";
	        }
	    }
	break;

    case "waiting_attack":
	    if (instance_exists(_step.attacker) && !_step.attacker.attack_active)
	    {
	        global.fight_attack_active = false;
	        scr_ui_show(pre_attack_ui_sprite);
			if (instance_exists(obj_friend)) { obj_friend.visible = true; }
			with (obj_fist_slam_cutscene) { visible = true; }

	        if (instance_exists(obj_soul))
	        {
	            instance_destroy(obj_soul);
	        }

	        box_inst.state = "closing";
	        state = "waiting_box_close";
	    }
	break;

	case "waiting_custom_attack":
	    if (!instance_exists(custom_inst))
	    {
	        global.fight_attack_active = false;
	        scr_ui_show(pre_attack_ui_sprite);

	        if (instance_exists(obj_friend)) { obj_friend.visible = true; }
	        with (obj_fist_slam_cutscene) { visible = true; }

	        if (instance_exists(obj_soul))
	        {
	            instance_destroy(obj_soul);
	        }

	        box_inst.state = "closing";
	        post_attack_delay = 60;
	        state = "waiting_box_close";
	    }
	break;
	
	case "waiting_barrage":
	    if (!instance_exists(obj_barrage_spawner))
	    {
	        state = "advance";
	    }
	break;
	
	case "waiting_fist_slam":
	    if (!instance_exists(obj_fist_slam_cutscene) || obj_fist_slam_cutscene.punch_complete)
	    {
	        state = "advance";
	    }
	break;

	case "waiting_custom_cutscene":
	    if (!instance_exists(custom_inst))
	    {
	        state = "advance";
	    }
	break;

    case "waiting_box_close":
	    if (!instance_exists(box_inst))
	    {
	        state = "advance";
	    }
	break;

    case "finished":
	    global.fight_seq_starting = false;
	    instance_destroy();
	break;
}