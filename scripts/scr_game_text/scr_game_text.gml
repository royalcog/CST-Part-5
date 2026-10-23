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
		// ---------------- Part 5: rm_two (obj_rm_two_p5 opens self_1, Z opens the rest)
		case "self_1":
			global.cutscene_lock = true;   // Queen walks in after this
			scr_text("* Susie!", "lancer", 12);
			scr_text("* ...", "susie", 31);
			scr_text("* Lancer?", "susie", 14);
				scr_call_on_page(function() { scr_set_sprite_keep_body(obj_susie, spr_susie_walk_down_upset); }, 1, global.page_number - 1);
			scr_text("* Are you guys okay?", "lancer", 10);
			scr_text("* We're fine, just...", "susie", 32);
			scr_text("* ...", "susie", 31);
			scr_text("* You shouldn't be here.", "susie", 30);
			scr_text("* ...", "lancer", 11);
			scr_text("* W-Why?", "lancer", 12);
			scr_text("* This Titan is going to wipe out Castle Town if we don't put all our effort in.", "ralsei", 35);
				scr_call_on_page(function() { scr_set_sprite_keep_body(obj_ralsei, spr_ralsei_walk_down_neutral); }, 1, global.page_number - 1);
			scr_text("* But...", "lancer", 11);
			scr_text("* I can be helpful!", "lancer", 1);
			scr_text("* I can help you guys beat up this thing, and...", "lancer", 9);
			scr_text("* ...", "susie", 31);
			scr_text("* Lancer, we don't want you getting hurt.", "susie", 30);
			scr_text("* We...", "susie", 31);
			scr_text("* You should stay with Queen.", "ralsei", 36);
			scr_text("* But Queen Is Already Here", "queen", 0);
				scr_custom_call_after_textbox_delayed(function() { with (obj_rm_two_p5) queen_enter(); }, 0);
		break;

		case "self_2":
			global.cutscene_lock = true;   // Lancer and Queen get on the chair after this
			scr_text("* I Took Care Of Our King Problem", "queen", 9);
				scr_call_on_page(function() { with (obj_queen) scr_set_sprite_keep_feet(id, spr_queen_walk_left_unhappy); }, 1, global.page_number - 1);
			scr_text("* ...", "lancer", 11);
			scr_text("* Don't Worry He's Just Taking A Nap", "queen", 23);
			scr_text("* Anyways Is This That Titan Thing Your Were Talking About", "queen", 0);
				scr_call_on_page(function() { with (obj_queen) scr_set_sprite_keep_feet(id, spr_queen_walk_up); }, 1, global.page_number - 1);
			scr_text("* ...Yes.", "ralsei", 45);
			scr_text("* Crap", "queen", 7);
			scr_text("* How Are We Going To Destroy This Thing", "queen", 5);
			scr_text("* Well first we need to get up there.", "ralsei", 40);
			scr_text("* We just remembered that Susie still has the Petal Feather, so...", "ralsei", 40);
			scr_text("* Why Don't I Just Like", "queen", 0);
			scr_text("* Chair You Guys Up", "queen", 1);
				scr_call_on_page(function() { with (obj_rm_two_p5) summon_chair(); }, 1, global.page_number - 1);
			scr_text("* ...", "ralsei", 45);
			scr_text("* So we can... practice the movement better?", "ralsei", 51);
			scr_text("* If You Say So", "queen", 22);
			scr_text("* Lancer Hop On The Chair", "queen", 0);
			scr_text("* We'll Meet You Guys At The Top", "queen", 3);
			scr_text("* ...", "lancer", 10);
				scr_custom_call_after_textbox_delayed(function() { with (obj_rm_two_p5) board_chair(); }, 0);
		break;

		case "self_3":
			global.cutscene_lock = true;   // the chair flies off after this
			scr_text("* Good Luck", "queen", 3);
				scr_custom_call_after_textbox_delayed(function() { with (obj_rm_two_p5) chair_liftoff(); }, 0);
		break;

		case "self_4":
			global.cutscene_lock = true;   // the Petal Feather, then the flash into the tower
			scr_text("* ...", "ralsei", 45);
			scr_text("* Let's...", "ralsei", 34);
			scr_text("* Let's go up there, Susie.", "ralsei", 40);
				scr_call_on_page(function() { scr_set_sprite_keep_body(obj_ralsei, spr_ralsei_walk_left_neutral); }, 1, global.page_number - 1);
			scr_text("* ...", "susie", 31);
				scr_custom_call_after_textbox_delayed(function() { with (obj_rm_two_p5) pull_feather(); }, 0);
		break;

		// ---------------- Part 5: the tower climb (obj_plat_controller opens self_5)
		case "self_5":
			scr_text("* This should get us up faster than just climbing...", "susie", 30);
			scr_text("* ...plus Kris has the climbing gloves.", "susie", 31);
			scr_text("* Let's just... try our best.", "ralsei", 34);
				scr_custom_call_after_textbox_delayed(function() { with (obj_plat_controller) begin_play(); }, 0);
		break;
		
		// ---------------- the tower climb: dialogue triggers (obj_plat_controller opens these, you keep playing)
		case "plat_flowers":
			scr_text("* Why are there flowers here...?", "susie", 30);
			scr_text("* Um...", "ralsei", 51);
			scr_text("* I'm not really... sure?", "ralsei", 45);
			scr_text("* ...", "susie", 31);
		break;
		
		case "plat_watchout":
			scr_text("* Watch out!", "susie", 39);
		break;

		case "plat_halfway":
			scr_text("* Are we gonna be able to beat this thing?", "susie", 31);
			scr_text("* I'm not sure...", "ralsei", 34);
			scr_text("* Last time you and Kris were able to seal it out, but...", "ralsei", 35);
			scr_text("* We don't need Kris for this, man.", "susie", 30);
				scr_call_on_page(function() { with (obj_plat_controller) susie_turn(); }, 1, global.page_number - 1);
			scr_text("* ...?", "ralsei", 50);
			scr_text("* We're both strong people.| We got this.", "susie", 34);
			scr_text("* And as much as I'm not a fan...", "susie", 32);
			scr_text("* We have Queen and Lancer too.", "susie", 30);
			scr_text("* This Titan is no match for us.", "susie", 34);
			scr_text("* ...", "ralsei", 45);
			scr_text("* I hope you're right, Susie.", "ralsei", 40);
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