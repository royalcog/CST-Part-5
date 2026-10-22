if (!variable_instance_exists(id, "duration")) duration = 600; // ~10s default, override per-use

timer = 0;

// same chase-and-punch behavior as attack2's scissors sub-attack, but this
// spawns its own hand from a random side instead of reusing an RPS-revealed
// one, so it can run standalone alongside other attacks
var _bounds = scr_get_attack_bounds();
var _side = choose("left", "right");
var _spawn_x = (_side == "left") ? (_bounds.x1 - 250) : (_bounds.x2 + 250);
var _spawn_y = lerp(_bounds.y1, _bounds.y2, 0.5);

chase_hand = instance_create_depth(_spawn_x, _spawn_y, -380, obj_rps_hand, { side: _side });
chase_hand.sprite_index = spr_friend_hand_scissors;
chase_hand.image_index = 0;
chase_hand.image_speed = 1; // plays through all frames of the snip animation
chase_hand.bouncing = false;
chase_hand.chasing = true;
chase_hand.chase_target_scale = 0.8;

chase_speed = 2.5;

trail_points = [];
trail_sample_timer = 0;
trail_sample_interval = 8;
trail_max_points = 12;

sub_timer = 45;
awaiting_punch = false;
punch_telegraph_side = "left";
punch_telegraph_perp = 0;