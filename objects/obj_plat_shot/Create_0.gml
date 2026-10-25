// an attack flying at a Titan Spawn: Susie's Rude Buster or Ralsei's fireball.
// made by obj_plat_player with kind/target/dir set right after; it homes in on its target
kind   = "buster";   // "buster" or "fire"
target = noone;      // the Titan Spawn it's after (noone = just flies straight)
dir    = 0;
depth  = -160;

// --- tuning ---
buster_sprite = spr_rudebuster_projectile;
buster_scale  = 2;
buster_speed  = 9.5;
buster_turn   = 10;    // degrees per frame it can turn toward its target
fire_sprite   = spr_plat_fireball;
fire_scale    = 2;
fire_speed    = 9.5;
fire_turn     = 10;
hit_r         = 26;    // px from a Titan Spawn that counts as a hit
life          = 150;   // frames before it gives up
trail_len     = 5;     // afterimages (buster only)

// --- state ---
t = 0;
trail = [];

/// turns this into kind _k (call right after creating it)
setup = function(_k, _target, _dir)
{
    kind   = _k;
    target = _target;
    dir    = _dir;
    sprite_index = (kind == "buster") ? buster_sprite : fire_sprite;
    image_xscale = (kind == "buster") ? buster_scale : fire_scale;
    image_yscale = image_xscale;
    image_speed  = 1;
    image_angle  = dir;
}