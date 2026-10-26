// Queen's DEFEND shield (obj_queen_shield): the battle menu calls these.

/// she picked DEFEND: the shield builds up in front of her (if it was being taken down, it builds again)
function scr_queen_shield_build()
{
    with (obj_queen_shield) if (state == "down") instance_destroy();
    if (instance_exists(obj_queen_shield)) return;
    instance_create_depth(0, 0, 0, obj_queen_shield);
}

/// DEFEND was undone before it was used: it's taken back down (it doesn't break)
function scr_queen_shield_takedown()
{
    with (obj_queen_shield) if (state == "build" || state == "up") { state = "down"; t = 0; }
}

/// the round's over: if it's still up, it breaks
function scr_queen_shield_break()
{
    with (obj_queen_shield) if (state == "build" || state == "up") shatter();
}

/// is it up and blocking right now
function scr_queen_shield_up()
{
    return instance_exists(obj_queen_shield) && obj_queen_shield.state == "up";
}