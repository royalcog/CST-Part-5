// --- tuning ---
start_delay = 40;
volleys     = [1, 2, 2, 3, 3, 4, 4]; // swords per volley (and how many volleys)
charge_a    = 85;   // charge time on the first volley...
charge_b    = 60;   // ...and the last
turn_at     = 0.4;  // how far into the charge the grid turns
turn_frames = 22;
volley_gap  = 35;   // breather after a volley clears
turn_sound  = snd_impact;
unwind      = true; // turn back upright at the end

// --- state ---
state     = "intro";
timer     = start_delay;
vi        = 0;
t         = 0;
charge    = 0;
turned    = false;
turn_from = 0;
turn_to   = 0;
turn_t    = -1;

start_turn = function(_delta)
{
    turn_from = obj_battlebox.box_angle;
    turn_to   = turn_from + _delta;
    turn_t    = 0;
    if (turn_sound != noone) audio_play_sound(turn_sound, 1, false);
}