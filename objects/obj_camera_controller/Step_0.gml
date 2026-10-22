if (panning)
{
    pan_timer++;
    var _t = clamp(pan_timer / pan_duration, 0, 1);
    var _eased_t = _t * _t * (3 - 2 * _t);
    cam_x = lerp(pan_start_x, pan_target_x, _eased_t);

    if (_t >= 1)
    {
        panning = false;
    }
}

var _shake_x = 0;
var _shake_y = 0;
if (shake_timer > 0)
{
    shake_timer--;
    _shake_x = random_range(-shake_intensity, shake_intensity);
    _shake_y = random_range(-shake_intensity, shake_intensity);
}

camera_set_view_pos(view_camera[0], cam_x + _shake_x, cam_y + _shake_y);

if (flipping)
{
    flip_timer++;
    var _ft = clamp(flip_timer / flip_duration, 0, 1);
    flip_angle = lerp(flip_start, flip_target, _ft);
    if (_ft >= 1)
    {
        flipping = false;
    }
}
if (tilting)
{
    tilt_timer++;

    var _amp = tilt_amplitude;
    if (tilt_ramping_in)
    {
        tilt_ramp_timer++;
        var _rt = clamp(tilt_ramp_timer / tilt_ramp_duration, 0, 1);
        _amp = lerp(0, tilt_amplitude, _rt);
        if (_rt >= 1) tilt_ramping_in = false;
    }

    tilt_offset = sin(tilt_timer * (2 * pi / tilt_period)) * _amp;
}
else if (tilt_stopping)
{
    tilt_stop_timer++;
    var _st = clamp(tilt_stop_timer / tilt_stop_duration, 0, 1);
    tilt_offset = lerp(tilt_stop_start, 0, _st);
    if (_st >= 1)
    {
        tilt_stopping = false;
        tilt_offset = 0;
    }
}

camera_set_view_angle(view_camera[0], flip_angle + tilt_offset);