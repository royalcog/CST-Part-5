// a Titan Spawn: floats toward whoever you're controlling. 3 hits and it's gone.
// touching it hurts (knockback + damage number). made by obj_plat_controller
sprite_index = spr_titanspawn_idle;
image_speed  = 1;
image_xscale = 2;
image_yscale = 2;
depth = -150;   // in front of Susie & Ralsei

// --- tuning ---
hp          = 3;
spd         = 1.3;       // px per frame, floating toward you
turn        = 0.04;      // how quickly it changes course (0-1)
bob_amp     = 4;         // px it bobs up and down
bob_speed   = 0.06;
touch_r     = 22;        // px around it that counts as touching you
damage_min  = 24;        // damage when it touches you
damage_max  = 36;
hit_sound   = snd_titanspawn;
hurt_sprite = spr_titanspawn_hurt;
hurt_len    = 18;        // frames it shudders on its hurt sprite
hurt_shake  = 3;         // px
hurt_push   = 3;         // px per frame it's knocked back by a hit
die_len     = 30;        // frames it fades out after the 3rd hit
faces_left  = true;      // the sprite looks left as drawn

// --- state ---
vx = 0; vy = 0;
bob = random(2 * pi);
hurt_t = 0;
dying  = false;
die_t  = 0;
base_y = y;
appear_t   = 0;
appear_len = 30;     // frames it fades in over (it can't hurt you until it's all the way in)
scripted  = false;   // the first one: it stops short of you and hovers, and can't hurt you
hold_dist = 180;

/// one hit from an attack (from _fx,_fy)
take_damage = function(_fx, _fy)
{
    if (dying) return;
    hp--;
    if (hit_sound != noone) audio_play_sound(hit_sound, 1, false);
    sprite_index = hurt_sprite;
    image_index  = 0;
    hurt_t = hurt_len;
    var _d = point_direction(_fx, _fy, x, base_y);
    vx = lengthdir_x(hurt_push, _d);
    vy = lengthdir_y(hurt_push, _d);
    if (hp <= 0) { dying = true; die_t = 0; }
}