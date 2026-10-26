// a Titan Spawn in the tower-top battle (made by obj_tower_top_scene). it drops in from above the screen to
// (home_x, home_y), easing to a stop, then bobs in place. drawn by its own sprite at 2x.
sprite_index = spr_titanspawn_idle;
image_xscale = 2;       // turned around to face the party (on the left)
image_yscale = 2;
image_speed  = 1;

// --- tuning ---
drop_time   = 40;       // frames to drop in
drop_delay  = 0;        // frames before it starts (the scene staggers them)
land_sound  = snd_titanspawn;
bob_amp     = 4;
bob_speed   = 0.06;

// --- state ---
home_x  = x;
home_y  = y;
from_y  = y;
state   = "wait";       // wait -> drop -> idle
t       = 0;
bob     = random(2 * pi);
landed  = false;


// --- as an enemy (obj_battle_menu) ---
enemy_name  = "Titan Spawn";
max_hp      = 400;
hp          = max_hp;
mercy       = 0;        // 0-100. at 100 its name goes yellow and SPARE works
tired_at    = 0.35;     // TIRED (Pacify / Scythemare work) at or below this much of its HP
check_text  = "* TITAN SPAWN - AT 12 DF 0\n* A fragment of the Titan. It hungers for light.";
hurt_t      = 0;        // frames left of the hurt sprite + shake
hurt_len    = 24;
targeted    = false;    // the menu's cursor is on it (it flashes)
gone        = false;    // defeated or spared: it's fading out, and doesn't count any more
gone_t      = 0;
spared      = false;

is_tired = function() { return !gone && hp <= max_hp * tired_at; }
is_alive = function() { return !gone; }

/// the menu hits it: damage number (in the attacker's colour), hurt sprite + shake. defeated at 0
take_hit = function(_amount, _col)
{
    if (gone) return noone;
    hp = max(0, hp - _amount);
    audio_play_sound(snd_damagetaken, 1, false);
    hurt_t = hurt_len;
    var _p = scr_trigger_damage_popup(id, _amount, _col, _col, 0, -sprite_get_yoffset(sprite_index) * image_yscale - 4, noone);
    if (hp <= 0) { gone = true; gone_t = 0; }
    return _p;
}

/// spared: it goes white and fades away
spare = function()
{
    if (gone) return;
    gone = true; spared = true; gone_t = 0;
    audio_play_sound(snd_spell_pacify, 1, false);
}