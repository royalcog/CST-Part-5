/// the end of the Knight fight. round 14's only line is { run: scr_knight_finale_begin }; from there
/// obj_knight_finale runs the whole scene (its `steps` list), with normal textboxes instead of TALKboxes.
/// the lines are scr_game_text cases "rk_finale_1" to "rk_finale_4"

/// the battle stops for good: no more rounds, UI + music gone, anyone swooned gets back up for the scene
function scr_knight_finale_begin()
{
    with (obj_king_turn_sequencer) instance_destroy(); // so it never loops back to round 1
    scr_knight_stop_battle();
    if (instance_exists(obj_UI)) obj_UI.active_box = noone;
    with (obj_battle_ui_box)
    {
        selected_attack = false;
        if (hp <= 0) scr_party_revive(id);
    }
    global.knight_finale_done = false;
    global.cutscene_lock = true; // pressing Z can't start some other dialogue in the middle of it
    if (!instance_exists(obj_knight_finale)) instance_create_depth(0, 0, -3500, obj_knight_finale);
}

function scr_knight_finale_play(_name)
{
    with (obj_knight_finale) play(_name);
}

function scr_knight_finale_idle()
{
    return !instance_exists(obj_knight_finale) || !obj_knight_finale.busy;
}

/// both of them made it to the door (the fade into the next room has started)
function scr_knight_finale_end()
{
    global.knight_finale_done = true;
    global.cutscene_lock = false;
    with (obj_knight_finale) instance_destroy();
}

/// round 14's dialogue: just starts the scene
function scr_knight_finale_batch(_rk_cps)
{
    return [ { run: scr_knight_finale_begin } ];
}