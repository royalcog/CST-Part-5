// --- tuning ---
start_delay   = 30;
warm_volleys  = 6;
warm_swords_a = 1;  warm_swords_b = 3;   // swords per warm-up volley, first -> last
warm_gap_a    = 70; warm_gap_b    = 40;  // frames between them
warm_charge_a = 60; warm_charge_b = 45;
big_charge    = 170; // every lane, both ways at once — only the barrier saves you
buster_delay  = 25;  // frames into the big charge before Susie swings
barrier_hold  = 120; // how long the barrier lasts after the big volley fires
end_delay     = 40;
susie_line    = [ { speaker: obj_susie, text: "Take this!" } ]; // placeholder

// --- state ---
state       = "intro";
timer       = start_delay;
vi          = 0;
big_t       = 0;
barrier_row = 1;
buster      = noone;

talk = function(_lines)
{
    var _c = instance_create_depth(0, 0, 0, obj_dialogue_chain);
    _c.batches = [ _lines ];
    return _c;
}