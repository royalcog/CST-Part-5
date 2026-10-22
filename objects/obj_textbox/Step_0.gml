if !variable_instance_exists(id, "ready") || !ready { exit; }

if (!variable_instance_exists(id, "shaking_obj")) shaking_obj = noone;

var _want_shake = speaker_shake[page] ? speaker_shake_obj[page] : noone;

// page changed to one that doesn't shake this object: put it back
if (shaking_obj != noone && shaking_obj != _want_shake && instance_exists(shaking_obj))
{
    scr_char_shake_stop(shaking_obj);
}
shaking_obj = _want_shake;

if (_want_shake != noone && instance_exists(_want_shake))
{
    scr_char_shake_update(_want_shake, speaker_shake_speed[page], speaker_shake_intensity[page]);
}