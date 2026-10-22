image_xscale = 2; // or whatever scale you're using
image_yscale = 2;
spd = 2;
scrolling = true;

tile_width = sprite_get_width(spr_trees_1) * image_xscale; // use YOUR actual normal sprite name

tiles = ds_list_create();
next_special_sprite = -1;
special_wait_time = 0;

special_tile_index = -1;

fade_active = false;
fade_tile_index = -1;
fade_old_sprite = noone;
fade_old_image = 0;
fade_new_sprite = noone;
fade_new_image = 0;
fade_alpha = 0;
fade_speed = 0.02;

var _cam_w = camera_get_view_width(view_camera[0]);
var _needed = ceil(_cam_w / tile_width) + 2;
var _start_x = 0;

for (var i = 0; i < _needed; i++)
{
    var _tile = { spr: spr_trees_1, x: _start_x }; // use YOUR actual normal sprite name
    ds_list_add(tiles, _tile);
    _start_x += tile_width;
}