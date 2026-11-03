// (attack 1's Step, plus the box breaking and the whole-screen half: losing the box isn't the end of it here)
t++;
var _goal = (phase == "full") ? full_aura : (variable_global_exists("soul_glow_radius") ? global.soul_glow_radius : 48);
aura_radius = scr_approach(aura_radius, _goal, abs(_goal - aura_radius) * 0.0513);

cast_update();
if (boom != undefined) { boom.f += 0.4; if (boom.f >= sprite_get_number(spr_titan_shockwave_bullet_explosion)) boom = undefined; }

switch (phase)
{
    case "box":
        if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
        if (t mod max(1, round(spawn_gap / spawn_rate)) == 0) spawn_shape();
        if (t >= break_at && cast == undefined) cast_start();
    break;

    case "breaking":   // the box is in pieces
        if (!instance_exists(obj_battlebox)) { phase = "full"; full_t = 0; }
    break;

    case "full":
        full_t++;
        if (full_t mod full_gap == 0) spawn_edge();
        if (full_t mod burst_every == 0) spawn_burst();
        if (t >= attack_duration) { phase = "end"; end_t = 0; global.attack_fullscreen = 2; }
    break;

    case "end":   // everything fades, then it's over
        end_t++;
        if (end_t >= end_fade) { instance_destroy(); exit; }
    break;
}

// the organ swells while something's being purified, fades when nothing is
if (in_light) ominous_volume = scr_approach(ominous_volume, 1, (1 - ominous_volume) * 0.075);
else          ominous_volume = scr_approach(ominous_volume, 0, 0.01);
flare = in_light ? min(1, flare + 0.06) : max(0, flare - 0.03);
burst = max(0, burst - 0.04);
if (instance_exists(obj_soul)) { glow_x = lerp(glow_x, obj_soul.x, 0.5); glow_y = lerp(glow_y, obj_soul.y, 0.5); }
in_light = false;
if (ominous_loop != -1) audio_sound_gain(ominous_loop, ominous_volume * ominous_max_gain, 0);

for (var i = array_length(particles) - 1; i >= 0; i--)
{
    var _p = particles[i];
    _p.x += lengthdir_x(_p.spd, _p.dir);
    _p.y += lengthdir_y(_p.spd, _p.dir);
    _p.size -= 0.1;
    if (_p.size <= 0) array_delete(particles, i, 1);
}