gpu_set_texrepeat(false);

for (var i = 0; i < ds_list_size(tiles); i++)
{
    var _tile = tiles[| i];
    draw_sprite_ext(_tile.spr, 0, _tile.x, y, image_xscale, image_yscale, 0, c_white, image_alpha);
}