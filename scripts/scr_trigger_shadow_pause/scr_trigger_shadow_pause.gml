function trigger_shadow_pause(_target_object, _sprite, _wait_seconds)
{
    with (_target_object)
    {
        var _cam_x = camera_get_view_x(view_camera[0]);
        var _cam_w = camera_get_view_width(view_camera[0]);
        var _cam_right = _cam_x + _cam_w;

        var _target_index = -1;
        var _best_x = infinity;

        for (var i = 0; i < ds_list_size(tiles); i++)
        {
            var _t = tiles[| i];
            if (_t.x >= _cam_right - tile_width && _t.x < _best_x)
            {
                _best_x = _t.x;
                _target_index = i;
            }
        }

        if (_target_index != -1)
        {
            tiles[| _target_index].spr = _sprite;
            special_tile_index = _target_index;
        }
    }
    _target_object.alarm[0] = game_get_speed(gamespeed_fps) * _wait_seconds;
}

function trigger_fade_special_sprite(_target_object, _new_sprite, _new_image, _fade_speed)
{
    with (_target_object)
    {
        if (special_tile_index != -1 && special_tile_index < ds_list_size(tiles))
        {
            var _t = tiles[| special_tile_index];
            fade_active = true;
            fade_tile_index = special_tile_index;
            fade_old_sprite = _t.spr;
            fade_old_image = variable_struct_exists(_t, "img") ? _t.img : 0;
            fade_new_sprite = _new_sprite;
            fade_new_image = _new_image;
            fade_alpha = 0;
            fade_speed = _fade_speed;
        }
        else
        {
            show_debug_message("Fade SKIPPED - invalid special_tile_index");
        }
    }
}

function trigger_pause_only(_target_object, _wait_seconds)
{
    _target_object.alarm[0] = game_get_speed(gamespeed_fps) * _wait_seconds;
}

function trigger_resume_scrolling(_target_object)
{
    _target_object.scrolling = true;
}