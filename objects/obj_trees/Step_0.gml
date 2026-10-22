if (scrolling)
{
    for (var i = 0; i < ds_list_size(tiles); i++)
    {
        tiles[| i].x -= spd;
    }

    var _cam_x = camera_get_view_x(view_camera[0]);
    var _cam_w = camera_get_view_width(view_camera[0]);

    while (ds_list_size(tiles) > 0 && tiles[| 0].x + tile_width < _cam_x)
    {
        ds_list_delete(tiles, 0);
    }

    var _last = tiles[| ds_list_size(tiles) - 1];
    while (_last.x + tile_width < _cam_x + _cam_w + tile_width)
    {
        var _new_spr = spr_trees;

        if (next_special_sprite != -1)
        {
            _new_spr = next_special_sprite;
            next_special_sprite = -1;
        }

        var _new_tile = { spr: _new_spr, x: _last.x + tile_width };
        ds_list_add(tiles, _new_tile);
        _last = _new_tile;
    }
}

function trigger_shadow_pause(_sprite, _wait_seconds)
{
    obj_trees.alarm[0] = game_get_speed(gamespeed_fps) * _wait_seconds;
}