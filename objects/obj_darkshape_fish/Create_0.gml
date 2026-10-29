// a darkshape fish (Deltarune's darkshape centipede). a head pulling body pieces along its path. it surges and
// slows as it swims, turning toward the SOUL (better at it the longer it lives). the light purifies each piece on
// its own: a purified piece turns into a grey orb that keeps riding along. purify the head and the whole thing
// goes: the rest of its body purifies in a ripple and every orb turns into COURAGE. (DR's numbers, converted)
ctrl   = noone;
damage = 110;

// --- tuning ---
pieces       = 5;        // body pieces behind the head (DR's for this pattern)
spacing      = 24;       // px between pieces along its path
tracking     = 18.4;     // how well it turns (DR: 16 x 1.15)...
tracking_max = 30;       // ...getting better over time, up to this
head_rate    = 0.0065;   // the head purifies at this in the light  [DR 0.013]
piece_rate   = 0.0105;   // each body piece  [DR 0.021]
recover      = 0.0015;   // un-purifies this fast out of it  [DR 0.003]
die_time     = 40;       // frames from the head purifying to it all going  [DR 20]
hit_head     = 10;
hit_piece    = 7;
art_scale    = 1;

// --- state ---
heading = 270;   // set by the attack
spd     = 0;
t       = 0;
hist    = [];
parts   = [];    // this frame's positions: { x, y, a }, [0] = the head
segs    = [];    // the body pieces: { light, orb, auto }
for (var i = 0; i < pieces; i++) array_push(segs, { light: 0, orb: noone, auto: -1 });
light   = 0;     // the head's
grow    = 0;
pop     = 1;     // the head swells when it's purified, then settles
dying   = false;
die_t   = 0;
fading  = false;
image_alpha = 0;
surging = false;

/// light specks + the organ swell for a piece that's in the light
lit_fx = function(_x, _y)
{
    if (!instance_exists(ctrl)) return;
    ctrl.in_light = true;
    if (!irandom(2) && instance_exists(obj_soul)) array_push(ctrl.particles, {
        x: _x + random_range(-10, 10), y: _y + random_range(-10, 10),
        dir: point_direction(obj_soul.x, obj_soul.y, _x, _y), spd: 0.5 + random(1.5), size: 2
    });
}