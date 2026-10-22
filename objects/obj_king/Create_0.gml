image_xscale = 2;
image_yscale = 2;
depth = -2000;
char_id = CharID.King;

king_hp = 3000;     // placeholder — tune once real attacks/pacing are in
king_max_hp = 3000;

// hurt-sprite flash: scr_king_damage swaps to spr_king_hurt and stashes whatever
// sprite/anim state King was in so Step can restore it once the flash ends
hurt_timer = 0;
hurt_duration = 30; // ~0.5s at 60fps
pre_hurt_sprite = sprite_index;
pre_hurt_image_index = image_index;
pre_hurt_image_speed = image_speed;