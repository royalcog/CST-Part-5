/// scr_fist_slam_split(_fist, _edge_margin, _lerp_speed, _fade_speed)
/// Starts the settled fist lerping toward the right edge of the screen;
/// once it arrives, spawns a mirrored, inverted clone near the left edge
/// that fades in in place.
function scr_fist_slam_split(_fist, _edge_margin = 40, _lerp_speed = 0.08, _fade_speed = 0.04)
{
    if (!instance_exists(_fist)) return noone;

    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam);
    var _vw = camera_get_view_width(_cam);

    with (_fist)
    {
        split_target_x   = _vx + _vw - _edge_margin; // near the right edge
        split_mirror_x   = _vx + _edge_margin;        // near the left edge
        split_move_lerp  = _lerp_speed;
        split_fade_speed = _fade_speed;
        phase = "split_move";
    }

    return _fist;
}