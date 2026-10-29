// a darkshape fish (attack 3): a head dragging a body, snaking toward the SOUL. the light purifies the whole fish,
// faster the more of it's in the light; it slows down while it's lit, and pops into COURAGE when it's done
ctrl   = noone;
damage = 110;

// --- tuning ---
pieces      = 6;       // body pieces behind the head (the last one's the tail)
spacing     = 18;      // px between pieces along its path
max_speed   = 1.4;
turn_rate   = 1.4;     // deg a frame it turns toward the SOUL
weave_amp   = 28;      // deg it snakes either side of its heading...
weave_speed = 0.06;    // ...this fast
light_rate  = 0.012;   // purify speed with one piece in the light...
light_extra = 0.5;     // ...+50% for every other piece in it too
light_recover = 0.004; // un-purifies this fast out of it
light_slow  = 0.6;     // slows to this while it's lit
pellets     = 3;       // COURAGE it drops
hit_head    = 10;
hit_piece   = 7;
art_scale   = 1;

// --- state ---
heading = 270;   // the attack sets this when it spawns it
dir     = 270;
spd     = 0;
t       = 0;
weave   = random(2 * pi);
hist    = [];    // where the head's been, newest first: the body follows it
parts   = [];    // this frame's pieces: { x, y, a }, [0] = the head
light   = 0;     // 0-1, purified at 1
lit     = false;
fading  = false;
image_alpha = 0;