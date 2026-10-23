// a Titan fish: a head, 4 body pieces and a tail, swimming across the arena just above the floor.
// the sprites face right as drawn. only the one you're controlling can be hit. made by obj_plat_battle
// x/y aren't used: it lives in "ox" (px across from the arena's middle) and y0, so the tower's seam can't split it

// --- tuning ---
segs       = 4;       // body pieces
gap        = 22;      // px (sprite px) between each piece's middle
tail_gap   = 20;
wave_amp   = 4;       // px each piece bobs up and down...
wave_speed = 0.22;    // ...this fast...
wave_lag   = 0.7;     // ...each one a little behind the one in front
hit_r      = 15;      // px (sprite px) around each piece's middle that hurts
damage_min = 20;
damage_max = 30;

// --- set by obj_plat_battle ---
arena  = undefined;
cam_y0 = 0;
dir    = 1;
spd    = 7.5;
scale  = 1.5;
y0     = 0;
ox     = 0;
warn_t = 0;

// --- state ---
phase   = random(2 * pi);
anim    = 0;
fading  = false;
alpha   = 1;

/// where piece _k is (0 = head, 1..segs = body, segs + 1 = tail): { ox, y }
piece = function(_k)
{
    var _back = (_k <= segs) ? _k * gap : segs * gap + tail_gap;
    return { ox: ox - dir * _back * scale, y: y0 + sin(phase - _k * wave_lag) * wave_amp };
}