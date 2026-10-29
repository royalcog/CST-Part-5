// a darkshape fish (attack 3): a head that can't be purified, dragging a body behind it.
// the SOUL's light burns it away from the tail end, one piece at a time (each piece drops COURAGE),
// and every piece it loses makes it faster and twitchier. once it's down to its head, the head can be purified too
ctrl   = noone;
damage = 110;

// --- tuning ---
pieces      = 6;       // body pieces behind the head (the last one's the tail)
spacing     = 18;      // px between pieces along its path
max_speed   = 1.4;
turn_rate   = 1.4;     // deg a frame it turns toward the SOUL
weave_amp   = 28;      // deg it snakes either side of its heading...
weave_speed = 0.06;    // ...this fast
light_rate  = 0.02;    // how fast the light burns the tail end (a copy purifies at 0.025)
head_rate   = 0.012;   // ...and the head, once it's alone
panic       = 1.12;    // speed / turning / snaking multiplier for every piece it's lost
hit_head    = 10;
hit_piece   = 7;
art_scale   = 1;

// --- state ---
pieces_start = pieces;
heading = 270;   // the attack sets this when it spawns it
dir     = 270;
spd     = 0;
t       = 0;
weave   = random(2 * pi);
hist    = [];    // where the head's been, newest first: the body follows it
parts   = [];    // this frame's pieces: { x, y, a }, [0] = the head
burn    = 0;     // how burnt the tail end is (0-1)
fading  = false;
image_alpha = 0;