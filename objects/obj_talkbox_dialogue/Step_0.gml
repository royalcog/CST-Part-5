scr_char_jolt_update(id);

if !global.move_active && !ds_queue_empty(global.move_queue)
{
    var _entry = ds_queue_dequeue(global.move_queue);
    global.move_current_obj = _entry.obj;
    global.move_current_target = _entry.target_x;
    global.move_current_speed = _entry.speed;
    global.move_active = true;
    global.cutscene = true;
}

if global.move_active && instance_exists(global.move_current_obj)
{
    global.move_current_obj.x = lerp(global.move_current_obj.x, global.move_current_target, global.move_current_speed);
    if abs(global.move_current_obj.x - global.move_current_target) < 1
	{
	    global.move_current_obj.x = global.move_current_target;
	    global.move_active = false;
	    if ds_queue_empty(global.move_queue)
	    {
	        global.cutscene = false;
	        if global.move_current_obj == obj_kris
	        {
	            obj_kris.sprite_index = spr_kris_battle_idle;
	            obj_kris.image_speed = 1;
	            obj_kris.image_index = 0;
				obj_kris.alarm[2] = 1;
	        }
	    }
	}
}
if keyboard_check_pressed(vk_space)
{
    show_debug_message("space pressed");
    show_debug_message("talkbox_tenna: " + string(global.talkbox_tenna));
    show_debug_message("kris exists: " + string(instance_exists(obj_kris)));
}

if keyboard_check_pressed(vk_space) && global.talkbox_tenna == 0 && instance_exists(obj_kris)
{
    var tenna = obj_tenna;
	var susie = obj_susie;
	var battat = obj_battat;
	var jongler = obj_jongler;
	var pluey = obj_pluey;
	var ralsei = obj_ralsei;
    var d = instance_create_layer(0, 0, "UI", obj_dialogue_chain);
    with (d) {
        entries = [];
		// different sprite changes: $, ^, `
		// @ = jolt (more @ = more jolts)
		
        batches = [
            [
                { speaker: ralsei, text: "$Wait, this song sounds familiar..."},
				{ speaker: tenna, text: "^Mike! Get out here!", reveal: true},
				{ speaker: battat, text: "What's up, boss?"},
				{ speaker: tenna, text: "...There's three of you?@"},
				{ speaker: battat, text: "Uhh..."},
				{ speaker: jongler, text: "You'se seeing things, boss."},
				{ speaker: tenna, text: "..."},
				{ speaker: tenna, text: "Guess I gotta get my motherboard checked out."},
            ],
			[
				{ speaker: battat, text: "Boss, ain't this our-"},
				{ speaker: battat, text: "I mean- uh..."},
				{ speaker: battat, text: "MY song?"},
				{ speaker: tenna, text: "No cats swinging in here, Mike!"},
				{ speaker: tenna, text: "$100% pure TV Time, all the time!"},
				{ speaker: battat, text: "^...Sure, Tenna."},
			],
			[
				{ speaker: tenna, text: "Ok, maybe there's a BIT of your song in here, Mike."},
				{ speaker: pluey, text: ":)"},
			],
			[
				{ speaker: tenna, text: "$My ratings are all jazzed up right now!"},
				{ speaker: tenna, text: "I can smell the excessive fame and fortune rolling in!"},
				{ speaker: jongler, text: "^Hows about you, maybe, uh, give us a raise, boss?"},
				{ speaker: tenna, text: "..."},
				{ speaker: tenna, text: "`Good one, Mike!!!"},
				{ speaker: pluey, text: "~:("},
				{ speaker: battat, text: "+^Who would've guessed..."},
			],
			[
				{ speaker: susie, text: "I'm so lost."},
				{ speaker: ralsei, text: "Aren't we all..."},
			],
        ];
    }
    global.talkbox_tenna = 1;
	global.talkbox_battat = 1;
	global.talkbox_jongler = 1;
	global.talkbox_susie = 1;
}
