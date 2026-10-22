// scr_text_shake(23, 28); -> Shake the letters between (and indcluding) x and y
// scr_text_color(23, 28, color, color, color, color); -> Turn the letters between (and indcluding) x and y different colors
// scr_text_face_spr(LEFT, spr_noelle_left_happy); -> Turning a sprite a direction (4-directional only)
// scr_obj_spawn_after_textbox(obj_desscircle, 680, 215, "Instances"); -> Spawning an object after the full textbox is done
// scr_obj_sprite_after_textbox(obj_dess, spr_dess_intro_body, false, snd_appear, 0.7); -> Sprite animation after textbox is done
// scr_obj_sprite_after_textbox_delayed(obj_dess, spr_dess_drool, true, 60); -> Same as above, but with a delay
// scr_text_speaker_shake(.5, 1); -> Shake the speaker during the line of text
// scr_text_cutoff_slow(11, 11, 0.1); -> Slows down the text, and cuts it off at letter x

/// @param text_id
function scr_game_text(_text_id)
{
	switch (_text_id)
	{
			case "self_1":
			// both walk up together
			scr_queue_movement_group_after_textbox([
				   { obj: obj_susie,  sprite: spr_susie_walk_up,  loop: true, dx: 0, dy: -4, speed: .9, duration: 90 },
				   { obj: obj_ralsei, sprite: spr_ralsei_walk_up, loop: true, dx: 0, dy: -4, speed: .8, duration: 90 }
			]);
			// once both are done: both walk left
			scr_queue_movement_group_after_textbox([
				   { obj: obj_susie,  sprite: spr_susie_walk_left_upset,    loop: true, dx: -4, dy: 0, speed: .9, duration: 40 },
				   { obj: obj_ralsei, sprite: spr_ralsei_walk_left_neutral, loop: true, dx: -4, dy: 0, speed: .8, duration: 60 }
			]);
			// once they stop: both turn right
			scr_queue_movement_group_after_textbox([
				   { obj: obj_susie,  sprite: spr_susie_walk_right_upset, loop: false, dx: 0, dy: 0, speed: 0, duration: 0 },
				   { obj: obj_ralsei, sprite: spr_ralsei_right_neutral,   loop: false, dx: 0, dy: 0, speed: 0, duration: 0 }
			]);
		break;
		
		
		case "self_2":
			scr_text("* Please...|* Don't do this...", "ralsei", 34);
			scr_text("* There's no gain to any of this...", "ralsei", 35);
			scr_text("* All you're doing is hurting everything and everyone, and...", "ralsei", 41);
			scr_obj_sprite_on_page(obj_ralsei, spr_ralsei_head_down_sad, false);
			scr_text("* What's it all for???", "susie", 39);
			scr_text("* How do you live with yourself???", "susie", 37);
			scr_text("* There is... no gain...", "knight");
				scr_obj_sprite_on_page(obj_ralsei, spr_ralsei_right_neutral, false);
				scr_text_slow(0.2);
				scr_text_shake(1, 99);
				scr_snd_on_page(snd_knight_phone_call, 1);
			scr_text("* This is all... just...", "knight");
				scr_text_slow(0.2);
				scr_text_shake(1, 99);
				scr_snd_on_page(snd_knight_phone_call, 1);
			scr_text("* Just what, huh?", "susie", 32);
			scr_text("* ...", "knight");
				scr_text_slow(0.2);
				scr_text_shake(1, 99);
				scr_snd_on_page(snd_knight_phone_call, 1);
			scr_text("* ...", "susie", 31);
			scr_text("* Fine.", "susie", 31);
			scr_text("* You want a chance at us?|* Again?", "susie", 32);
			scr_text("* After we kicked your ass the last time?", "susie", 33);
			scr_text("* Fine.", "susie", 31);
			scr_text("* Fine fine fine.|* By all means.", "susie", 32);
			scr_text("* Susie, I don't think...", "ralsei", 27);
			scr_text("* Too late.|* Already made up my mind.", "susie", 33);
			scr_text("* Is that... so...", "knight");
				scr_text_slow(0.2);
				scr_text_shake(1, 99);
				scr_snd_on_page(snd_knight_phone_call, 1);

				// Susie draws her weapon (plays once, holds the last frame)
				scr_custom_call_after_textbox_delayed(function()
				{
				    scr_set_battle_sprite(obj_susie, spr_susie_battle_intro, spr_susie_battle_idle, false);
				    audio_play_sound(snd_taking_out_sword, 1, false);
				}, 0);
		break;
		
		case "self_3":
			scr_text("* Hell yeah it is.", "susie", 34);
			scr_text("* ...", "ralsei", 45);

				// Ralsei draws (Susie already did at the end of self_2), then the battle starts
				scr_custom_call_after_textbox_delayed(function()
				{
				    scr_set_battle_sprite(obj_ralsei, spr_ralsei_battle_intro, spr_ralsei_battle_idle, false);
				    audio_play_sound(snd_taking_out_sword, 1, false);

				    scr_call_on_anim_frame(obj_ralsei, spr_ralsei_battle_intro, sprite_get_number(spr_ralsei_battle_intro) - 1, function()
				    {
				        scr_call_after_frames(function()
				        {
				            scr_set_battle_sprite(obj_susie,  spr_susie_battle_idle,  noone, true);
				            scr_set_battle_sprite(obj_ralsei, spr_ralsei_battle_idle, noone, true);

				            scr_duo_ui_setup();

				            scr_start_knight_battle();
				        }, 15);
				    });
				}, 0);
		break;
		
		// ---------------- Knight fight finale (obj_knight_finale opens these)
		case "rk_finale_1":
			scr_text("* Nice try, as", "susie", 34);
				scr_text_cutoff_skip(14); // cut off the moment it's typed
		break;

		case "rk_finale_2":
			scr_text("* Enough.", "knight");
				scr_text_slow(0.2);
				scr_text_shake(1, 99);
				scr_snd_on_page(snd_knight_phone_call, 1);
		break;

		case "rk_finale_3":
			scr_text("* I admire your cleverness, heroes.", "king", 0);
			scr_text("* But your defense is nothing for our strategy.", "king", 4);
			scr_text("* C-Crap...", "susie", 31);
		break;

		case "rk_finale_4":
			scr_text("* Come on!", "susie", 18);
		break;
		
		case "rm1_susie_point":
			scr_text("* What do you think you're doing???", "susie", 39);
		break;

		case "rm1_ralsei_no":
			scr_text("* N-No...", "ralsei", 34);
			scr_text("* NO!!!", "ralsei", 42);
		break;
		
		case "rm2_ralsei_plead":
			// every line cuts off the moment it's typed and jumps to the next, except the last one
			var _lines = [
				["* You don't have to do this",          42],
				["* It's not worth it",                  44],
				["* What are you gaining",               43],
				["* Please don't do it",                 40],
				["* The Prophecy doesn't say anything",  45],
				["* This is all a mistake",              43],
				["* I didn't do anything wrong",         42],
				["* Please leave us alone",              41],
				["* Please leave",                       41],
				["* Please",                             41]
			];
			for (var i = 0; i < array_length(_lines); i++)
			{
				scr_text(_lines[i][0], "ralsei", _lines[i][1]);
					scr_text_cutoff_skip(string_length(_lines[i][0]));
			}

			scr_text("* DON'T DO IT!!!", "ralsei", 42);
				scr_text_shake(1, 99);
		break;
		
		case "rm2_ralsei_watchout":
			scr_text("* Watch out!", "ralsei", 42);
		break;
		
		// ---------------- after the Titan (rm_two)
		case "self_4":
			scr_text("* We...", "ralsei", 34);
			scr_text("* We can't let...", "ralsei", 35);
				// Susie gets up: mirrored so she keeps facing the same way, and kept on the same spot
				scr_custom_call_after_textbox_delayed(function()
				{
				    if (!instance_exists(obj_susie)) return;
				    with (obj_susie)
				    {
				        var _b = scr_get_body(id);
				        sprite_index = spr_susie_getup;
				        image_xscale = -image_xscale;   // the get-up faces the other way as drawn
				        image_index  = 0;
				        image_speed  = 1;
				        anim_loop    = false;
				        var _n = scr_get_body(id);
				        x += _b.x - _n.x;
				        y += _b.y - _n.y;
				        last_sprite = sprite_index;     // placed by hand: End Step leaves it alone
				    }
				    scr_call_on_anim_frame(obj_susie, spr_susie_getup, sprite_get_number(spr_susie_getup) - 1, function()
				    {
				        scr_call_after_frames(function()
				        {
				            with (obj_susie)
				            {
				                var _b = scr_get_body(id);
				                sprite_index = spr_susie_left_neutral;
				                image_xscale = abs(image_xscale);   // still facing left
				                image_index  = 0;
				                image_speed  = 0;
				                anim_loop    = true;
				                var _n = scr_get_body(id);
				                x += _b.x - _n.x;
				                y += _b.y - _n.y;
				                last_sprite = sprite_index;
				            }
				        }, 10);
				    });
				}, 20);
		break;

		case "self_5":
			scr_text("* We're not gonna let them hurt Castle Town.", "susie", 32);
			scr_text("* We're...", "susie", 31);
			scr_text("* ...", "susie", 31);
			scr_text("* Where did they...", "susie", 31);
			scr_text("* Never mind that!", "ralsei", 46);
			scr_text("* We have to clear this Titan!", "ralsei", 45);
			scr_text("* But without Kris...", "susie", 31);
			scr_text("* We have to do our best.", "ralsei", 40);
			scr_text("* ...", "susie", 31);
				// Ralsei gets up, on the same spot
				scr_custom_call_after_textbox_delayed(function()
				{
				    with (obj_ralsei)
				    {
				        var _b = scr_get_body(id);
				        sprite_index = spr_ralsei_right_neutral;
				        image_xscale = abs(image_xscale);
				        image_index  = 0;
				        image_speed  = 0;
				        anim_loop    = true;
				        var _n = scr_get_body(id);
				        x += _b.x - _n.x;
				        y += _b.y - _n.y;
				        last_sprite = sprite_index;
				    }
				}, 20);
		break;

		case "self_6":
			global.cutscene_lock = true;   // the rest plays out on its own
			scr_text("* How are we gonna get up there???", "susie", 39);
				scr_obj_sprite_on_page(obj_susie, spr_susie_walk_up, false);
				scr_obj_sprite_on_page(obj_ralsei, spr_ralsei_walk_up, false);
			scr_text("* I...", "ralsei", 34);
			scr_text("* ...", "ralsei", 45);
			scr_text("* Wait!", "ralsei", 12);
			scr_text("* Susie, do we still have the...", "ralsei", 35);
			scr_text("* ...", "susie", 31);
			scr_text("* Hell yeah we do.", "susie", 34);
				scr_fade_warp_with_music(rm_three, 240, noone, 1, 1000, 1500);
		break;

		// ---------------- Lancer & Queen (rm_three, obj_rm_three_scene opens these)
		case "rm3_1":
			scr_text("* Do You Feel Better", "queen", 0);
			scr_text("* I guess...", "lancer", 10);
		break;

		case "rm3_2":
			scr_text("* ...", "lancer", 11);
			scr_text("* Girldad?", "lancer", 6);
			scr_text("* Yes Sweetie", "queen", 3);
			scr_text("* What's... that...?", "lancer", 4);
			scr_text("* Huh", "queen", 18);
		break;

		case "rm3_3":
			scr_text("* What The Hell", "queen", 8);
			scr_text("* We gotta go help them!", "lancer", 12);
			scr_text("* ...", "queen", 5);
		break;

		// ---------------- the ending (rm_zero, obj_rm_zero_ending opens these)
		case "rm0_1":
			scr_text("* D-Dad!", "lancer", 12);
		break;

		case "rm0_2":
			scr_text("* Dad, what happened?|* What's going on?", "lancer", 7);
			scr_text("* It's... already over, my son...", "king", 1);
			scr_text("* What Did You Do", "queen", 16);
			scr_text("* A new world will arise amidst the darkness...", "king", 2);
			scr_text("* We will...", "king", 3);
			scr_text("* We will do what no other Darkener has ever dreamed of...", "king", 1);
			scr_text("* ...", "lancer", 11);
			scr_text("* You...", "lancer", 10);
			scr_text("* You're a...", "lancer", 12);
			scr_text("* ...", "king", 3);
			scr_text("* My son...", "king", 1);
			scr_text("* ...", "lancer", 11);
		break;

		case "rm0_3":
			scr_text("* You're A Terrible Person", "queen", 19);
			scr_text("* I Hope You Take That To Your Grave", "queen", 11);
		break;

		case "rm0_4":
			scr_text("* ...", "king", 5);
			scr_text("* Do what you have to d", "king", 0);   // obj_rm_zero_ending cuts this off as the pie lands
				scr_obj_sprite_on_page(obj_king, spr_king_kneel_happy, false);
		break;
/*

*/


		/*array_push(obj_cutscenehandler_midfightattacks.after_textbox_queue, {
			type: "tenna_battle_intro"
			});*/
				
	
		/* Warp Code:
		if (instance_exists(obj_cutscenehandler_midfightattacks))
			    {
			        obj_cutscenehandler_midfightattacks.waiting_for_warp = true;
			    }
		*/
		
		/* Pitching Music:
			global.song = { sound: sng_?, bpm: ?, beats: ? };
			global.music = audio_play_sound(sng_?, 1, true);
			audio_sound_pitch(global.music, 0.7);
			global.song_start = current_time;
		*/
		/* Summoning UI (Not in battle):
			if (instance_exists(obj_UI))
			{
			    instance_destroy(obj_UI);
			}
			instance_create_depth(0, 0, -5000, obj_UI);
		    audio_stop_all();
		    global.song = { sound: sng_cmmm, bpm: 130, beats: 9999 };
			global.music = audio_play_sound(sng_cmmm, 1, true);
			audio_sound_pitch(global.music, 1.25);
			global.song_start = current_time;
		*/
		
		/* Movement Queue:
			scr_queue_movement_group_after_textbox([
				   { obj: obj_gerson, sprite: spr_gerson_hammer_walkright_lantern, loop: true, dx: 15, dy: 3, speed: .2, duration: 75 },
				   { obj: obj_mewmew, sprite: spr_ghost_shocked_left, loop: false, dx: 0, dy: -10, speed: .2, duration: 75 }
			]);
		*/
		
		// Battle Example:
		/* case "self_18":
			if (instance_exists(obj_UI))
			{
			    instance_destroy(obj_UI);
			}
			instance_create_depth(0, 0, -5000, obj_UI);
		    obj_UI.sprite_index = spr_UI_Pink;
			obj_mewmew.sprite_index = spr_ghost_shocked_left;
		    var pink = obj_mewmew;
		    var _seq = instance_create_depth(0, 0, 0, obj_fight_sequencer);
		    _seq.sequence = [
				{
			        type: "ui_sequence",
			        steps: [
			            { sprite: spr_UI_Pink, delay: 30 },
			            { sprite: spr_UI_Pink_Defend, snd: snd_select_reverb, delay: 30 },
			        ]
			    },
		        { type: "talk", batch: [ { speaker: pink, text: "Hey! Hey!!! HEY!!!"} ] },
				{ type: "talk", batch: [ { speaker: pink, text: "GERSON!!! I'M ON YOUR SIDE!!!" } ] },
				{ type: "talk", batch: [ { speaker: pink, text: "WHAT'S GOING ON???" } ] },
		        { type: "attack", attacker: obj_sound_of_justice, data: global.atk_sound_of_justice_hammers },
				{
			        type: "ui_sequence",
			        steps: [
			            { sprite: spr_UI_Pink, delay: 30 },
			            { sprite: spr_UI_Pink_Defend, snd: snd_select_reverb, delay: 30 },
			        ]
			    },
		        { type: "talk", batch: [ { speaker: pink, text: "DIDN'T WE PLAN TO DO THIS???" } ] },
				{ type: "talk", batch: [ { speaker: pink, text: "WHY ARE YOU ATTACKING ME???" } ] },
		        { type: "attack", kind: "custom", start_func: scr_start_giant_hammer_attack },
				{
			        type: "ui_sequence",
			        steps: [
			            { sprite: spr_UI_Pink, delay: 30 },
			            { sprite: spr_UI_Pink_Defend, snd: snd_select_reverb, delay: 30 },
			        ]
			    },
				{ type: "talk", batch: [ { speaker: pink, text: "You know I can't take damage... right???" } ] },
				{ type: "talk", batch: [ { speaker: pink, text: "So... quit it!!!" } ] },
				{ type: "attack", kind: "custom", start_func: scr_start_falling_hammer_attack },
				{
			        type: "ui_sequence",
			        steps: [
			            { sprite: spr_UI_Pink, delay: 30 },
			            { sprite: spr_UI_Pink_Defend, snd: snd_select_reverb, delay: 30 },
			        ]
			    },
				{ type: "sprite", target: obj_mewmew, new_sprite: spr_ghost_wistful },
				{ type: "talk", batch: [ { speaker: pink, text: "We need to... find my body..." } ] },
				{ type: "sprite", target: obj_mewmew, new_sprite: spr_ghost_yelling_right },
				{ type: "talk", batch: [ { speaker: pink, text: "Damn it, Gerson, don't you double-cross me too!!!" } ] },
				{ type: "sprite", target: obj_mewmew, new_sprite: spr_ghost_shocked_left },
				{ type: "attack", kind: "custom", start_func: scr_start_gavel_slam_attack },
				{
			        type: "ui_sequence",
			        steps: [
			            { sprite: spr_UI_Pink, delay: 30 },
			            { sprite: spr_UI_Pink_Defend, snd: snd_select_reverb, delay: 30 },
			        ]
			    },
				{ type: "sprite", target: obj_mewmew, new_sprite: spr_ghost_wistful },
				{ type: "talk", batch: [ { speaker: pink, text: "Come on, Gerson. I don't want to fight you." } ] },
				{ type: "talk", batch: [ { speaker: pink, text: "So stop fighting me..." } ] },
		        // add more talk/attack pairs as you write more dialogue/attacks
		    ];		
		break;
		
		case "self_19":
			scr_ui_reverse(sng_empty);
			audio_stop_all();
			scr_text("* Please...", "mewmewghost");
				scr_portrait_on_page(spr_pinkghost_scared);
	        scr_portrait_tail_off();
	        scr_snd_after_textbox(snd_sojlaugh, 1);
	        scr_obj_sprite_after_textbox(obj_sound_of_justice, spr_sound_of_justice_laugh, true);
	        scr_custom_call_after_textbox_delayed(scr_spawn_soj_hit_hammer, 113); // mid-laugh hammer hit
			scr_obj_sprite_after_textbox_delayed(obj_mewmew, spr_ghost_shocked_left, false, 120);
	        scr_custom_call_after_textbox_delayed(scr_start_pan_and_reveal_left, 150); // shortly after the hit
		break;
	*/
	}
}