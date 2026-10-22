for (var i = 0; i < ds_list_size(tiles); i++)
{
    var _tile = tiles[| i];
    var _img = variable_struct_exists(_tile, "img") ? _tile.img : 0;

    if (fade_active && i == fade_tile_index)
    {
        draw_sprite_ext(fade_old_sprite, fade_old_image, _tile.x, y - 80, image_xscale, image_yscale, 0, c_white, 1 - fade_alpha);
        draw_sprite_ext(fade_new_sprite, fade_new_image, _tile.x, y - 80, image_xscale, image_yscale, 0, c_white, fade_alpha);
    }
    else
    {
        draw_sprite_ext(_tile.spr, _img, _tile.x, y - 80, image_xscale, image_yscale, 0, c_white, image_alpha);
    }
}