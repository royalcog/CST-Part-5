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


// --- as an enemy (obj_battle_menu). stats are Deltarune's Titan Spawn ---
enemy_name  = "Titan Spawn";
max_hp      = 1200;
hp          = max_hp;
at          = 18;       // its bullets do about at * 5 to whoever they hit (for when its attacks are built)
df          = 0;
rudebuster_mult = 0.5;  // Rude Buster does half damage to them, like the game
can_spare   = false;    // they can't be spared: they have to be fought (or banished, which only Kris can do)
no_mercy_text = "* ...it was not something that can understand MERCY.";
mercy       = 0;
tired_at    = 0.35;     // (only matters for things that can be spared)
check_text  = "* TITAN SPAWN - AT 30 DF 200\n* A shard of fear. Appears in places of deep dark.";
hurt_t      = 0;        // frames left of the hurt sprite + shake
hurt_len    = 24;
targeted    = false;    // the menu's cursor is on it (it flashes)
gone        = false;    // defeated or spared: it's going away, and doesn't count any more
gone_t      = 0;
spared      = false;

// defeated: it turns red, then it's sliced into strips that drift apart into red mist (Deltarune's violent defeat)
die_red_time   = 14;    // frames it goes red and shudders
die_slice_time = 40;    // frames the strips drift apart and fade
die_strip_h    = 2;     // each strip, in the sprite's own px
die_drift      = 70;    // px the strips spread by the end
mist           = [];    // the red specks floating off
// spared (not used for the Titan Spawn, but here for anything that can be): it goes white and stars burst out
star_count     = 8;
stars          = [];

is_tired = function() { return !gone && hp <= max_hp * tired_at; }
is_alive = function() { return !gone; }

/// the menu hits it: damage number (in the attacker's colour), hurt sprite + shake. defeated at 0
take_hit = function(_amount, _col)
{
    if (gone) return noone;
    hp = max(0, hp - _amount);
    // the hit + its cry (two hits landing at once still only play each once)
    if (instance_exists(obj_battle_menu)) { obj_battle_menu.play_once(snd_damagetaken); obj_battle_menu.play_once(snd_titanspawn); }
    else { audio_play_sound(snd_damagetaken, 1, false); audio_play_sound(snd_titanspawn, 1, false); }
    hurt_t = hurt_len;
    var _p = scr_trigger_damage_popup(id, _amount, _col, _col, 0, -sprite_get_yoffset(sprite_index) * image_yscale - 4, noone);
    if (hp <= 0) { gone = true; gone_t = 0; }
    return _p;
}

/// spared: it goes white and fades, with the spare stars bursting out (Deltarune's spr_sparestar_anim)
spare = function()
{
    if (gone || !can_spare) return;
    gone = true; spared = true; gone_t = 0;
    audio_play_sound(snd_spell_pacify, 1, false);
    for (var i = 0; i < star_count; i++)
    {
        var _a = i * 360 / star_count + random(20);
        array_push(stars, { x: x, y: y, dir: _a, spd: random_range(2, 3.5), rot: random(360), vr: random_range(-8, 8), f: 0 });
    }
}