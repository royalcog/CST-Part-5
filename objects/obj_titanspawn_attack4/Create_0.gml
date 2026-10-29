event_inherited();
// Titan Spawn attack 4: Deltarune's darkshapesspeedup (the real turn 2, then every other turn). copies + a red
// every 5th, but the spawn point sweeps around the box: faster and faster, snaps back, again. 1 in 9 lands on
// the opposite side. a bit closer in than normal
attack_duration = 720;
red_every       = 5;
spawn_gap       = 32;          // [DR every 16]
spawn_scale     = 1;
random_offset   = irandom(360);
speedup_timer   = 0;

spawn_pos = function(_half)
{
    var _d = random_offset + radtodeg(tan(speedup_timer * 0.01875));   // DR's tan sweep (0.0375 a frame at 30fps)
    if (!irandom(8)) _d += 180;
    return { dir: _d, dist: _half + 45 + irandom(50) };                // DR 120-170 (vs 150-200 normally)
}