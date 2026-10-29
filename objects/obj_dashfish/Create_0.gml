// a Titan fish dashing straight across the battle box (attack 3), like the climb's fish lanes.
// a red "!" flashes on its row first. the light can't touch it: dodge it
damage    = 110;
dir       = 1;       // 1 = left to right, -1 = right to left (set by the attack)
y0        = 0;       // the row it swims along (set by the attack)

// --- tuning ---
warn_time = 36;      // frames the "!" flashes first
spd       = 5;       // px a frame
segs      = 4;       // body pieces
gap       = 18;      // px between pieces
tail_gap  = 16;
wave_amp  = 3;       // px each piece wiggles...
wave_speed = 0.25;   // ...this fast...
wave_lag  = 0.7;     // ...each a little behind the one in front
hit_r     = 8;
art_scale = 1;

// --- state ---
t     = 0;
hx    = 0;           // the head's x (set by the attack, just off the box's edge)
phase = random(2 * pi);
anim  = 0;
fading = false;
alpha  = 1;

/// where piece _k is: 0 = head, 1..segs = body, segs + 1 = tail
piece = function(_k)
{
    var _back = (_k <= segs) ? _k * gap : segs * gap + tail_gap;
    return { x: hx - dir * _back, y: y0 + sin(phase - _k * wave_lag) * wave_amp };
}