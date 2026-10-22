// all of these get overwritten by obj_king_spade_attack right after spawning
lx = x;           // position in the box's own (unrotated) frame
ly = y;
dir = 1;          // 1 = moving right, -1 = moving left (in the box's frame)
move_speed = 4;
damage = 36;
hit_radius = 12;
travel_out = 60;  // how far past the far wall it keeps going before fading out
image_speed = 0;

fade_frames = 8;
fading_out = false;
image_alpha = 0;  // fades in on spawn so it doesn't just pop into existence