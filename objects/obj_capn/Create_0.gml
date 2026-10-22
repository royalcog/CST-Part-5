depth = -bbox_bottom;
var _sb = instance_create_depth(x, y, depth, obj_speakblock);
_sb.text_id = "cap'n";
_sb.text_id_2 = "cap'n_2";
_sb.text_id_3 = "cap'n_3";
_sb.owner = id;
_sb.interact_range = 20;
_sb.dialogue_flag = "cap'n";
char_id = CharID.Capn;
image_xscale = 2;
image_yscale = 2;

//moving
start_x = x;
start_y = y;
move_phase = 0;
move_timer = 0;
move_speed = 1.5;