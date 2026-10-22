// follow owner
x = owner.x;
y = owner.y;

// interaction
var _facing = obj_kris.face;
var _px = obj_kris.x;
var _py = obj_kris.y;

var _correct_dir = 
    (_facing == RIGHT && _px < x) ||
    (_facing == LEFT && _px > x) ||
    (_facing == DOWN && _py < y) ||
    (_facing == UP && _py > y);

if dialogue_flag != ""
{
    if !variable_global_exists("dialogue_" + dialogue_flag)
    {
        variable_global_set("dialogue_" + dialogue_flag, 0);
    }
    var _count = variable_global_get("dialogue_" + dialogue_flag);

        if keyboard_check_pressed(ord("Z")) && distance_to_object(obj_kris) < interact_range
&& !instance_exists(obj_textbox) && (!instance_exists(obj_cutscenefade) || (obj_cutscenefade.hold_black && obj_cutscenefade.fade_alpha >= 1) || obj_cutscenefade.fade_color == c_white) && !global.warp_pending && !global.fight_seq_starting && !global.cutscene_lock && !instance_exists(obj_king_turn_sequencer) && (ignore_facing || _correct_dir)
	{
	    // build a text id based on count, falling back to the last defined one
	    var _ids = [
		    text_id, text_id_2, text_id_3, text_id_4, text_id_5,
		    text_id_6, text_id_7, text_id_8, text_id_9, text_id_10,
		    text_id_11, text_id_12, text_id_13, text_id_14, text_id_15,
		    text_id_16, text_id_17, text_id_18, text_id_19, text_id_20,
		    text_id_21, text_id_22, text_id_23, text_id_24, text_id_25,
		    text_id_26, text_id_27, text_id_28, text_id_29, text_id_30,
		    text_id_31, text_id_32, text_id_33, text_id_34, text_id_35,
		    text_id_36, text_id_37, text_id_38, text_id_39, text_id_40,
		    text_id_41, text_id_42, text_id_43, text_id_44, text_id_45,
		    text_id_46, text_id_47, text_id_48, text_id_49, text_id_50
		]; // add as many as you need

	    var _last = _ids[array_length(_ids) - 1];
	    var _pick = _count < array_length(_ids) ? _ids[_count] : _last;
    
	    // skip empty entries, fall back to last valid
	    if _pick == "" _pick = _last;
    
	    create_textbox(_pick);
		variable_global_set("dialogue_" + dialogue_flag, _count + 1);	
	}
}
else
{
if keyboard_check_pressed(ord("Z")) && distance_to_object(obj_kris) < interact_range
&& !instance_exists(obj_textbox) && (!instance_exists(obj_cutscenefade) || (obj_cutscenefade.hold_black && obj_cutscenefade.fade_alpha >= 1) || obj_cutscenefade.fade_color == c_white) && !global.warp_pending && !global.fight_seq_starting && !global.cutscene_lock && !instance_exists(obj_king_turn_sequencer)
    {
        create_textbox(text_id);
    }
}