/// how hard the climb is at height _y in this room: 0 near the bottom (the first stretch is always easy), 1 at the top.
/// each obstacle reads this when it's made, so the same obstacle is gentler low down and nastier higher up
function scr_plat_difficulty(_y)
{
    var _calm = 400;   // px up from the bottom of the room that stay at 0
    return clamp((room_height - _y - _calm) / max(1, room_height - _calm - 80), 0, 1);
}