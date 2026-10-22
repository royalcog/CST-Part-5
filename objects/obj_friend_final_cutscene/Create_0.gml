phase = "commence_talk";
timer = 0;

// how long "Let us commence" gets to type out before the sword interrupts it —
// tune this to land the cutoff wherever looks best mid-sentence
commence_cutoff_frames = 35;

dialogue_inst = noone;
sword_inst = noone;

// Knight now gets placed just off the LEFT edge of the current view (mirrors
// the pan/hit direction below), and the camera pans LEFT to reveal him
knight_reveal_margin = 100;  // how far past the left edge of the view he sits
camera_pan_distance = 250;   // how far left the camera pans to bring him into frame
camera_pan_duration = 180;

dialogue_inst = instance_create_depth(0, 0, 0, obj_dialogue_chain);
dialogue_inst.batches = [
    [ { speaker: obj_friend, text: "Let us commence", keep_animating: true } ]
];