// a mini Titan Spawn (Deltarune's obj_darkshape). homes in on the soul; in the soul's light it slows, shrivels, and is purified
ctrl        = noone;
damage      = 90;
dir         = 270;

// --- Deltarune's values, converted to 60fps (originals in brackets) ---
speed_max       = 1.125;  // [2.25]
accel           = 0.0375; // [0.15]
tracking_val    = 32;     // [16] turns 1/32 of the way toward the soul each frame
light_rate      = 0.025;  // [0.05] purify speed in the light
light_recover   = 0.005;  // [0.01] un-purifies this fast out of it
pushback_radius = 48;     // copies push each other apart inside this
scalefactor     = 1;

// --- ours ---
art_scale  = 2;           // Deltarune's sprites at your battle scale (the Titan Spawn's drawn at 2x)
anim_speed = 0.125;       // frames per step of its flying animation
hit_mult   = 0.5;         // hit if within radius * this + 6 of the soul (radius shrinks 20 -> 8 as it's purified)

anim_sprite   = spr_darkshape_animated;   // flying (8 frames)
shrink_sprite = spr_darkshape;            // shrivelling in the light (6 frames)

// --- state ---
myspeed = 0;
light   = 0;
stage   = 0;
radius  = 20;
grow    = 0;
anim_f  = 0;
fading  = false;
image_alpha = 0;
image_speed = 0;

audio_play_sound(snd_dark_odd, 1, false, 0.25, 0, 0.35 + random(0.35));