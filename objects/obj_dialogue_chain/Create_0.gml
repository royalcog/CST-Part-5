entries       = [];
index         = 0;
curr_box      = noone;
default_wrap  = 200;
default_cps   = 0.4;
offx = [];
offy = [];
offx[CharID.Capn] = -20;
offy[CharID.Capn] = -8;
offx[CharID.Susie] = 70;
offy[CharID.Susie] = -16;
offx[CharID.Ralsei] = 65;
offy[CharID.Ralsei] = -17;
offx[CharID.Noelle] = 65;
offy[CharID.Noelle] = -20;
offx[CharID.Battat] = 103;
offy[CharID.Battat] = -50;
offx[CharID.Jongler] = -70;
offy[CharID.Jongler] = -90;
offx[CharID.Pluey] = -30;
offy[CharID.Pluey] = -68;
offx[CharID.Tenna] = -60;
offy[CharID.Tenna] = -90;
offx[CharID.Pink] = 60;
offy[CharID.Pink] = -10;
offx[CharID.Gerson] = 70;
offy[CharID.Gerson] = -10;
offx[CharID.Spamton] = 60;
offy[CharID.Spamton] = -10;
offx[CharID.Jevil] = 62;
offy[CharID.Jevil] = -8;
offx[CharID.Friend] = -49;
offy[CharID.Friend] = 35;
offx[CharID.Queen] = 70; // placeholder — tune to taste
offy[CharID.Queen] = -67;
offx[CharID.King] = 35; // placeholder — tune to taste
offy[CharID.King] = 95;
offx[CharID.Knight] = 90; // placeholder — tune to taste
offy[CharID.Knight] = 82;
offx[CharID.Lancer] = 20;  // (his mouth, facing right)
offy[CharID.Lancer] = -45;

if (!variable_global_exists("dbg_friend_offx")) { global.dbg_friend_offx = offx[CharID.Friend]; }
if (!variable_global_exists("dbg_friend_offy")) { global.dbg_friend_offy = offy[CharID.Friend]; }

if (global.DEBUG_BARRAGE)
{
    offx[CharID.Friend] = global.dbg_friend_offx;
    offy[CharID.Friend] = global.dbg_friend_offy;
}
flip = [];
flip[CharID.Capn] = false;
flip[CharID.Susie] = true;
flip[CharID.Ralsei] = true;
flip[CharID.Noelle] = true;
flip[CharID.Tenna] = false;
flip[CharID.Battat] = true;
flip[CharID.Jongler] = false;
flip[CharID.Pluey] = false;
flip[CharID.Pink] = true;
flip[CharID.Gerson] = true;
flip[CharID.Friend] = false;
flip[CharID.Spamton] = true;
flip[CharID.Jevil] = true;
flip[CharID.Queen] = true; // placeholder — tune to taste
flip[CharID.King] = false; // placeholder — tune to taste
flip[CharID.Knight] = false; // placeholder — tune to taste
flip[CharID.Lancer] = true;
next_delay = 0;
// --- which way someone's facing comes from their flip above (true: their bubble opens to the right, so they face
//     right as drawn). if their sprite's mirrored (a negative image_xscale), everything flips the other way ---
// --- auto_mouth: the bubble's tip goes a set distance in front of the speaker's mouth, worked out from their sprite
//     (its top and how tall it is) instead of the fixed offx / offy above. whoever makes the chain turns it on ---
auto_mouth   = false;
mouth_height = 0.3;   // the mouth: this far down from the top of their sprite (0 = top, 1 = feet)
mouth_reach  = 0.6;   // ...and this far from the middle of their sprite toward its front edge (0 = middle, 1 = the very
                      // front: that's often a weapon or a cape, not their face)
mouth_gap    = 6;     // px out in front of that to the bubble's tip
dim_timer = 0;
dim_phase = 1;
target_alpha = 0.4;
dim_speed = 0.02;
batches = [];
batch_index = 0;
run_done = false;