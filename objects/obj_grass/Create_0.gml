spd = 2;
scrolling = true;

tile_width = sprite_get_width(spr_grass) * image_xscale; // <-- add * image_xscale here

tiles = ds_list_create();
next_special_sprite = -1;
special_wait_time = 0;

var _cam_w = camera_get_view_width(view_camera[0]);
var _needed = ceil(_cam_w / tile_width) + 2;
var _start_x = 0;

for (var i = 0; i < _needed; i++)
{
    var _tile = { spr: spr_grass, x: _start_x };
    ds_list_add(tiles, _tile);
    _start_x += tile_width;
}
