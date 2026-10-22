// --- tuning ---
box_scale        = 1;     // box size during this attack (1 = normal)
start_delay      = 20;    // beat after the soul appears before the first star
star_count       = 10;
spawn_gap        = 40;    // frames between stars appearing
spawn_dist       = 30;    // how far outside the box they appear
appear_frames    = 25;    // fade in + hold still before they start hunting
star_scale       = 1.25;
max_speed        = 1.4;   // the soul moves at 2, so it can always outrun them
accel            = 0.03;  // how quickly they get up to speed
turn_rate        = 1.6;   // degrees per frame they can turn toward the soul
separation       = 26;    // stars push apart when closer than this
star_hit_radius  = 9;
star_damage      = 25;

attack_length    = 520;   // frames from the first star to the explosion
glow_frames      = 70;    // how long they glow red before going off
glow_slow        = 0.35;  // speed multiplier while glowing (so the burst is fair)
glow_pulse       = 0.15;  // how much they swell while glowing

shard_count      = 8;
shard_scale      = 0.5;
shard_speed      = 3.2;   // starting speed...
shard_friction   = 0.92;  // ...slows down fast so they don't go far (~40px)
shard_life       = 70;
shard_fade       = 20;
shard_spin       = 6;     // degrees per frame
shard_hit_radius = 5;
shard_damage     = 45;

hit_color_top    = c_white;
hit_color_bottom = c_white;
explode_sound    = snd_explosion;
explode_shake    = 3;
flash_frames     = 14;
flash_radius     = 34;

// --- state ---
t        = 0;   // counts once the first star is due
timer    = start_delay;
started  = false;
spawned  = 0;
next_spawn = 0;
stars    = [];
shards   = [];
flashes  = [];
exploded = false;
fade_out = 1;   // whole attack fades if the box closes under it
last_side = -1;

if (instance_exists(obj_battlebox))
{
    obj_battlebox.target_scale_x = box_scale;
    obj_battlebox.target_scale_y = box_scale;
}

soul_x = function() { return instance_exists(obj_soul) ? obj_soul.x : scr_box_center().x; }
soul_y = function() { return instance_exists(obj_soul) ? obj_soul.y : scr_box_center().y; }