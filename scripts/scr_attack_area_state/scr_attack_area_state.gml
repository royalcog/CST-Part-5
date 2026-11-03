/// is there somewhere for an attack's bullets to be? "ok", "fade" (it's closing: fade out) or "gone" (no box: go).
/// an attack that breaks its box open sets global.attack_fullscreen (1 while it's on, 2 while it's ending) so its bullets
/// keep going over the whole screen
function scr_attack_area_state()
{
    if (instance_exists(obj_battlebox)) return (obj_battlebox.state == "closing") ? "fade" : "ok";
    if (variable_global_exists("attack_fullscreen"))
    {
        if (global.attack_fullscreen == 1) return "ok";
        if (global.attack_fullscreen == 2) return "fade";
    }
    return "gone";
}