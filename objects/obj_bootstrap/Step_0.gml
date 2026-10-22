if (global.DEBUG_BARRAGE)
{
    if (keyboard_check(vk_left))  global.dbg_friend_offx -= 1;
    if (keyboard_check(vk_right)) global.dbg_friend_offx += 1;
    if (keyboard_check(vk_up))    global.dbg_friend_offy -= 1;
    if (keyboard_check(vk_down))  global.dbg_friend_offy += 1;

    if (keyboard_check_pressed(vk_f1) && instance_exists(obj_friend))
    {
        var _chain = instance_create_depth(0, 0, 0, obj_dialogue_chain);
        _chain.batches = [ [ { speaker: obj_friend, text: "Test line for offset tuning.", no_animate: true } ] ];
    }
}

if (keyboard_check_pressed(vk_f4))
{
    scr_controls_toggle();
    show_debug_message(global.wasd_on ? "Controls: WASD + arrows" : "Controls: arrows only");
}