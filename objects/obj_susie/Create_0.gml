bob_offsets = [0, 0, -1, -1, 0, 0, 1, 1];
bob_index = 0;
bob_timer = 0;
bob_speed = 1000000; //normal: 4.5
start_y = y;
char_id = CharID.Susie;
depth = -2000;
image_xscale = 2;
image_yscale = 2;
anim_loop = true;

// sprites whose origins are already hand-aligned with her standing sprites
keep_feet_skip = [spr_susie_point_right, spr_susie_point_up, spr_susie_angry,
                  spr_susie_battle_intro, spr_susie_battle_idle, spr_susie_attack_ready, spr_susie_hurt,
                  spr_susie_item, spr_susie_itemready, spr_susie_defend];