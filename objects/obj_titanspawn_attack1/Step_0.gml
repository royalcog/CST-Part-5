if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

t++;
if (variable_global_exists("soul_glow_radius")) aura_radius = global.soul_glow_radius;

if (t mod spawn_gap == 0) spawn_shape();
if (t >= attack_duration) { instance_destroy(); exit; }   // the box closes and whatever's left fades

// the organ swells while something's being purified, fades when nothing is
if (in_light) ominous_volume = scr_approach(ominous_volume, 1, (1 - ominous_volume) * 0.075);
else          ominous_volume = scr_approach(ominous_volume, 0, 0.01);
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