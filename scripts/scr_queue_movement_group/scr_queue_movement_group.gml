function scr_queue_movement_group(_moves)
{
    if (!instance_exists(obj_cutscenehandler_midfightattacks)) exit;
    array_push(obj_cutscenehandler_midfightattacks.movement_queue, { moves: _moves });
}

function scr_queue_movement_group_now(_moves)
{
    if (!instance_exists(obj_cutscenehandler_midfightattacks)) exit;
    array_push(obj_cutscenehandler_midfightattacks.movement_queue, { moves: _moves });
}