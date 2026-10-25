// a Titan fish: a head, 4 body pieces and a tail. the sprites face right as drawn. only the one you're controlling
// can be hit. made by obj_plat_battle and obj_plat_fishlane.
// sideways (vert = false): it lives in "ox" (px across from arena.cx) at height y0, swimming along just above a floor.
// up/down  (vert = true):  it stays at "ox" across, and its head moves along "oy" (room y), dir 1 = down, -1 = up
// (x/y aren't used, so the tower's seam can't split it)

// --- tuning ---
segs       = 4;       // body pieces
gap        = 22;      // px (sprite px) between each piece's middle
tail_gap   = 20;
wave_amp   = 4;       // px each piece wiggles...
wave_speed = 0.22;    // ...this fast...
wave_lag   = 0.7;     // ...each one a little behind the one in front
hit_r      = 15;      // px (sprite px) around each piece's middle that hurts
damage_min = 20;
damage_max = 30;

// --- set by whoever made it ---
arena  = undefined;
cam_y0 = 0;
vert   = false;
dir    = 1;
spd    = 7.5;
scale  = 1.5;
y0     = 0;
ox     = 0;
oy     = 0;
warn_t = 0;
loop   = false;   // true: never leaves, just keeps swimming round the tower (fish lanes)
owner  = noone;   // the fight that made it, if any

// --- state ---
phase   = random(2 * pi);
anim    = 0;
fading  = false;
alpha   = 1;

/// where piece _k is (0 = head, 1..segs = body, segs + 1 = tail): { ox, y }
piece = function(_k)
{
    var _back = ((_k <= segs) ? _k * gap : segs * gap + tail_gap) * scale;
    var _wig  = sin(phase - _k * wave_lag) * wave_amp;
    if (vert) return { ox: ox + _wig, y: oy - dir * _back };
    return { ox: ox - dir * _back, y: y0 + _wig };
}