// hit effects on a Titan Spawn.
//  "swarm"  (Ralsei's fireball): 3 fires swarm around it, then burst into a ring of small ones
//  "buster" (Susie's Rude Buster): a quick flash of the projectile blowing out
depth = -170;

// --- tuning ---
swarm_count  = 3;
swarm_sprite = spr_plat_fire;
swarm_scale  = 1.1;     // "not terribly big"
swarm_len    = 22;      // frames they swirl in
swarm_r_from = 46;      // px out they start...
swarm_r_to   = 6;       // ...and how close they end up
swarm_spin   = 14;      // degrees per frame
burst_count  = 8;
burst_sprite = spr_plat_smallfire;
burst_scale  = 1.6;
burst_speed  = 4.5;
burst_len    = 22;
burst_sound  = snd_bomb;

buster_len   = 14;

// --- state ---
kind   = "swarm";
target = noone;
t = 0;
cx = x; cy = y;
spin0  = random(360);
bursts = [];
burst_done = false;

setup = function(_kind, _target)
{
    kind   = _kind;
    target = _target;
}