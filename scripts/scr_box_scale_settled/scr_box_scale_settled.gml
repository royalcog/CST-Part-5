/// @function scr_box_scale_settled()
/// @description Returns true once obj_battlebox's current scale has actually
/// caught up to its target scale (within a small epsilon).
function scr_box_scale_settled()
{
    if (!instance_exists(obj_battlebox)) return true;

    var _bb = obj_battlebox;
    return (abs(_bb.image_xscale - _bb.target_scale_x) < 0.01)
        && (abs(_bb.image_yscale - _bb.target_scale_y) < 0.01);
}