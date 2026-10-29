if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

t++;
// the light grows in at the start of the attack, easing out (DR's light aura: 10% of the way each frame at 30fps)
var _goal = variable_global_exists("soul_glow_radius") ? global.soul_glow_radius : 48;
aura_radius = scr_approach(aura_radius, _goal, abs(_goal - aura_radius) * 0.0513);

if (t mod max(1, round(spawn_gap / spawn_rate)) == 0) spawn_shape();
if (t >= attack_duration) { instance_destroy(); exit; }   // the box closes and whatever's left fades

// the organ swells while something's being purified, fades when nothing is
if (in_light) ominous_volume = scr_approach(ominous_volume, 1, (1 - ominous_volume) * 0.075);
else          ominous_volume = scr_approach(ominous_volume, 0, 0.01);
// the light reacts too: it flares while it's burning something away, and pulses when one goes
flare = in_light ? min(1, flare + 0.06) : max(0, flare - 0.03);
burst = max(0, burst - 0.04);
if (instance_exists(obj_soul)) { glow_x = lerp(glow_x, obj_soul.x, 0.5); glow_y = lerp(glow_y, obj_soul.y, 0.5); }
in_light = false;
if (ominous_loop != -1) audio_sound_gain(ominous_loop, ominous_volume * ominous_max_gain, 0);

// the white specks coming off copies in the light
for (var i = array_length(particles) - 1; i >= 0; i--)
{
    var _p = particles[i];
    _p.x += lengthdir_x(_p.spd, _p.dir);
    _p.y += lengthdir_y(_p.spd, _p.dir);
    _p.size -= 0.1;   // DR 0.2
    if (_p.size <= 0) array_delete(particles, i, 1);
}