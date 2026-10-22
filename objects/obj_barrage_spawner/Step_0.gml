if (is_undefined(data)) exit;

if (spawn_index >= array_length(data.throws))
{
    if (instance_number(obj_barrage_projectile) == 0)
    {
        instance_destroy();
    }
    exit;
}

var _throw = data.throws[spawn_index];

switch (phase)
{
    case "wait":
        phase_timer++;
        if (phase_timer >= _throw.pre_delay)
        {
            phase_timer = 0;
            phase = "anticipate";
        }
    break;

    case "anticipate":
        phase_timer++;
        if (phase_timer >= _throw.anticipation_frames)
        {
            phase_timer = 0;
            phase = "wait_after";
            if (_throw.throw_poof != noone && instance_exists(_throw.source_obj))
            {
                var _poof = instance_create_depth(_throw.source_obj.x, _throw.source_obj.y, -1100, obj_barrage_impact_fx);
                _poof.sprite_index = _throw.throw_poof;
            }
            scr_spawn_throw(data.target_inst, _throw);
            spawn_index++;
        }
    break;

    case "wait_after":
        phase_timer++;
        if (phase_timer >= data.interval)
        {
            phase_timer = 0;
            phase = "wait";
        }
    break;
}