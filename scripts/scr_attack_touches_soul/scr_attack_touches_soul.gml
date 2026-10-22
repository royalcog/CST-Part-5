/// @function scr_attack_touches_soul()
/// @description Returns true if the CALLING instance's sprite (wherever its
/// origin is, at its current position/rotation/scale) touches the soul's
/// origin point. Point-in-mask instead of mask-vs-mask, so a big sprite with
/// an off-center origin (rotated hands, hammers, etc.) still registers a hit
/// the moment any visible part of it reaches the soul, rather than only
/// when the attacker's own origin point overlaps the soul's small mask.
function scr_attack_touches_soul()
{
    return instance_exists(obj_soul) && position_meeting(obj_soul.x, obj_soul.y, id);
}