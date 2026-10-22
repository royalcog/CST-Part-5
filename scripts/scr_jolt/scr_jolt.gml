function scr_char_jolt(_obj, _amount, _duration)
{
    if !variable_instance_exists(_obj, "jolt_timer")
    {
        variable_instance_set(_obj, "jolt_timer", 0);
        variable_instance_set(_obj, "jolt_x", 0);
        variable_instance_set(_obj, "jolt_start_x", _obj.x);
    }
    _obj.jolt_timer = _duration;
    _obj.jolt_start_x = _obj.x;
    _obj.jolt_amount = _amount;
}

function scr_char_jolt_update(_obj)
{
    if variable_instance_exists(_obj, "jolt_timer") && _obj.jolt_timer > 0
    {
        _obj.jolt_timer--;
        var _amt = variable_instance_exists(_obj, "jolt_amount") ? _obj.jolt_amount : 3;
        _obj.x = _obj.jolt_start_x + (_obj.jolt_timer mod 2 == 0 ? _amt : -_amt);

        // jolt just ended: put her back once, then stop touching x
        if _obj.jolt_timer == 0
        {
            _obj.x = _obj.jolt_start_x;
        }
    }
}