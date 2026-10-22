obj_kris.face = RIGHT;
obj_kris.image_speed = 0;
obj_susie.sprite_index = spr_susie_walk_up;
obj_ralsei.sprite_index = spr_ralsei_walk_up;

// Knight starts already floating (bob + shadow trail) instead of waiting for a fly-in
with (obj_knight)
{
    ball_phase = 3;
    start_y = y;
    bob_angle = 0;
    shadow_timer = 0;
}