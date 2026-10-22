function scr_extend_bg_left(_strip_tiles_wide, _bg_layer_name)
{
    var _src_layer = layer_get_id(_bg_layer_name);
    var _src_map = layer_tilemap_get_id(_src_layer);
    var _tileset = tilemap_get_tileset(_src_map);
    var _tile_w = tilemap_get_tile_width(_src_map);
    var _map_h = tilemap_get_height(_src_map);
    var _src_w = tilemap_get_width(_src_map);

    var _new_layer = layer_create(layer_get_depth(_src_layer), "bg_extension_layer");
    var _new_map = layer_tilemap_create(_new_layer, -(_strip_tiles_wide * _tile_w), 0, _tileset, _strip_tiles_wide, _map_h);

    for (var cx = 0; cx < _strip_tiles_wide; cx++)
    {
        for (var cy = 0; cy < _map_h; cy++)
        {
            var _src_x = cx mod _src_w; // wraps/repeats the pattern
            var _tile_data = tilemap_get(_src_map, _src_x, cy);
            tilemap_set(_new_map, _tile_data, cx, cy);
        }
    }
}