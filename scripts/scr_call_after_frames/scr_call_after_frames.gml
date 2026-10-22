function scr_call_after_frames(_func, _frames)
{
    var _inst = instance_create_depth(0, 0, 0, obj_delayed_caller);
    _inst.call_func = _func;
    _inst.frames_left = _frames;
    _inst.mode = "immediate";
    return _inst;
}

function scr_call_on_page(_func, _frames, _page)
{
    var _inst = instance_create_depth(0, 0, 0, obj_delayed_caller);
    _inst.call_func = _func;
    _inst.frames_left = _frames;
    _inst.mode = "on_page";
    _inst.target_page = _page;
    return _inst;
}

function scr_call_after_textbox(_func, _frames)
{
    var _inst = instance_create_depth(0, 0, 0, obj_delayed_caller);
    _inst.call_func = _func;
    _inst.frames_left = _frames;
    _inst.mode = "after_textbox";
    return _inst;
}

/// calls _func once _obj's animation (_sprite) reaches _frame
function scr_call_on_anim_frame(_obj, _sprite, _frame, _func)
{
    var _inst = instance_create_depth(0, 0, 0, obj_delayed_caller);
    _inst.call_func = _func;
    _inst.mode = "on_frame";
    _inst.target = _obj;
    _inst.target_sprite = _sprite;
    _inst.target_frame = _frame;
    return _inst;
}