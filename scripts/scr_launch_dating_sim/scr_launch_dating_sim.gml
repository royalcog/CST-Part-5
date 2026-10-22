// Launcher script example
function scr_launch_dating_sim()
{
    show_debug_message("Launching dating sim overlay...");
    
    var _inst = instance_create_depth(0, 0, -9999, obj_dating_overlay);
    _inst.current_portrait = spr_friendmew_questioning;
    _inst.lines = [
        "Line 1 of dialogue...",
        "Line 2 of dialogue..."
    ];
}