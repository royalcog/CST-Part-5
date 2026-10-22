function scr_camera_pan_to(_target_x, _duration)
{
    with (obj_camera_controller)
    {
        pan_start_x = cam_x;
        pan_target_x = _target_x;
        pan_timer = 0;
        pan_duration = _duration;
        panning = true;
    }
}

function scr_camera_shake(_intensity, _duration)
{
    with (obj_camera_controller)
    {
        shake_intensity = _intensity;
        shake_timer = _duration;
    }
}

function scr_screen_flip_to(_target_angle, _duration)
{
    with (obj_camera_controller)
    {
        flip_start = flip_angle;
        flip_target = _target_angle;
        flip_timer = 0;
        flip_duration = _duration;
        flipping = true;
    }
}

function scr_screen_flip_busy()
{
    return instance_exists(obj_camera_controller) && obj_camera_controller.flipping;
}

function scr_camera_tilt_start(_amplitude, _period, _ramp_in_duration = 60)
{
    with (obj_camera_controller)
    {
        tilting = true;
        tilt_stopping = false;
        tilt_timer = 0;
        tilt_amplitude = _amplitude;
        tilt_period = _period;

        tilt_ramping_in = _ramp_in_duration > 0;
        tilt_ramp_timer = 0;
        tilt_ramp_duration = _ramp_in_duration;
    }
}

function scr_camera_tilt_stop()
{
    with (obj_camera_controller)
    {
        if (tilting)
        {
            tilting = false;
            tilt_stopping = true;
            tilt_stop_start = tilt_offset;
            tilt_stop_timer = 0;
        }
    }
}

function scr_start_pan_and_reveal_left()
{
    scr_extend_bg_left(10, "Tiles_1");
    scr_camera_pan_to(camera_get_view_x(view_camera[0]) - 150, 180);
    scr_call_after_frames(scr_mid_pan_reveal, 90);
}

function scr_start_pan_and_reveal_right()
{
    scr_extend_bg_right(10, "Tiles_1");
    scr_camera_pan_to(camera_get_view_x(view_camera[0]) + 150, 180);
    scr_call_after_frames(scr_mid_pan_reveal, 90);
}

function scr_mid_pan_reveal()
{
    if (instance_exists(obj_mewmew)) && obj_mewmew.needtoflip == true
    {
        obj_mewmew.image_xscale *= -1;
		obj_mewmew.needtoflip = false;
    }
    // gerson stays silhouette here — his sprite only changes in scr_gerson_lantern_on
}