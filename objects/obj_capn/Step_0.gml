if keyboard_check_pressed(vk_space) && global.talkbox_capn == 0 {
    var capn = instance_nearest(x, y, obj_capn);
	var susie = instance_nearest(x, y, obj_susie);
    var d = instance_create_layer(0, 0, "UI", obj_dialogue_chain);
    with (d) {
        entries = [];
        batches = [
            [
                { speaker: capn, text: "Ain't my getup schway?"},
				{ speaker: capn, text: "Sweet kept telling me that it wasn't 'me'."},
				{ speaker: capn, text: "Guess who isn't me now?"},
				{ speaker: capn, text: "Him..."},
            ],
            [
                { speaker: capn, text: "Gonna play this for all the fine madamoizels later..."},
				{ speaker: capn, text: "Wait, was I thinking out loud-"},
				{ speaker: capn, text: "Heck yeah I was!"},
				{ speaker: capn, text: "(Can you guys send this to all your madamoizel friends?)"},
            ],
			[
				{ speaker: capn, text: "You people look like con-oh-soors of some pirated music."},
				{ speaker: capn, text: "And yeah, the pun IS intended!"},
			],
			[
				{ speaker: capn, text: "If I got a madamoizel to join my crew..."},
				{ speaker: capn, text: "I guess they would be my madamoizatey?"},
				{ speaker: capn, text: "Can't let them hamper my schway getup though."},
				{ speaker: capn, text: "Those madamoizateys do love their fashion."},
			],
			[
				{ speaker: capn, text: "I hope Sweet and K_K join my crew..."},
				{ speaker: capn, text: "Gets pretty lonely up here without any madamoizateys."},
			],
			[
				{ speaker: capn, text: "What'd I say guys, ain't this beat supa-schway?"},
				{ speaker: capn, text: "Glad you all liked it so much."},
				{ speaker: susie, text: "No one said anything, dude."},
				{ speaker: capn, text: "Silence speaks in beats, sweet madamoizel."},
			],
			[
				{ speaker: capn, text: "Wait..."},
				{ speaker: susie, text: "Don't even ask."},
				{ speaker: capn, text: "It was worth a try."},
			]
        ];
    }
    global.talkbox_capn = 1;
}