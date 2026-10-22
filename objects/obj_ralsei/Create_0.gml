bob_offsets = [0, 0, -1, -1, 0, 0, 1, 1];
bob_index = 0;
bob_timer = 0;
bob_speed = 1000000; //normal: 4.5
start_y = y;
depth = -3000;
image_xscale = 2;
image_yscale = 2;
anim_loop = true;
char_id = CharID.Ralsei;

// battle sprites have hand-aligned origins, so swapping between them shouldn't re-anchor
keep_feet_skip = [spr_ralsei_battle_intro, spr_ralsei_battle_idle, spr_ralsei_attack_ready,
                  spr_ralsei_attack, spr_ralsei_shocked, spr_ralsei_spellready, spr_ralsei_spell];