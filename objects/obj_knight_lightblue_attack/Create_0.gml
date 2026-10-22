// --- tuning ---
buster_delay        = 60;  // box open -> Susie's Rude Buster
taunt_delay         = 20;  // box breaks -> "How do you like that, huh?"
shake_delay         = 90;  // her line closes -> the soul starts shaking
shake_frames        = 50;
shake_amount        = 3;   // px at full strength (a jolt is about 1-2)
shake_sound         = snd_charge;
change_sound        = snd_sparklegem;
change_gain         = 1.5;  // a bit louder than normal
change_flash_frames = 20;
change_flash_radius = 40;
reaction_hold       = 90;  // everyone stays shocked this long before Susie talks
test_delay          = 45;  // her line closes -> the box comes back
glide_lerp          = 0.12; // the soul drifting back to the middle while the box reopens

susie_taunt = [ { speaker: obj_susie, text: "How do you like that, huh?" } ];
susie_react = [ { speaker: obj_susie, text: "...Huh?" } ]; // placeholder: her line once the soul's turned light blue

// --- state ---
state      = "wait_buster";
timer      = buster_delay;
buster     = noone;
chain      = noone;
soul       = instance_exists(obj_soul) ? instance_find(obj_soul, 0) : noone;
box2       = noone;
swords     = noone;
shake_x    = 0;
shake_y    = 0;
shake_snd  = -1;
flash_t    = 0;
flash_x    = 0;
flash_y    = 0;
shocked    = []; // who actually went shocked (only they get stood back up)

talk = function(_lines)
{
    var _c = instance_create_depth(0, 0, 0, obj_dialogue_chain);
    _c.batches = [ _lines ];
    return _c;
}