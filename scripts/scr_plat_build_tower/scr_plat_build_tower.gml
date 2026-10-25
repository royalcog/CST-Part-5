/// gets the tilemap on tile layer _name (making the layer if it isn't there), sized _w x _h cells, using _tileset
function scr_plat_tilemap(_name, _tileset, _w, _h)
{
    var _lay = layer_exists(_name) ? layer_get_id(_name) : layer_create(50, _name);
    var _tm  = layer_tilemap_get_id(_lay);
    if (_tm == -1) _tm = layer_tilemap_create(_lay, 0, 0, _tileset, _w, _h);
    else
    {
        tilemap_tileset(_tm, _tileset);
        tilemap_set_width(_tm, _w);
        tilemap_set_height(_tm, _h);
    }
    return _tm;
}

/// builds a stretch of the tower climb from a text map (one string per 40px row). see rm_tower2's creation code.
/// _paint_tiles = false: leave the ledges to the room editor, and only place the start point and obstacles from the map.
/// (it never touches the deco layers: those are only ever what's in the room editor)
function scr_plat_build_tower(_map, _paint_tiles = true, _tileset = tlst_flowergarden)
{
    var _ts   = 40;
    var _rows = array_length(_map);
    var _cols = string_length(_map[0]);
    var _ledge = -1;

    if (_paint_tiles)
    {
        _ledge = scr_plat_tilemap("Tiles_Ledge", _tileset, _cols, _rows);
        tilemap_clear(_ledge, 0);
    }

    /// is cell (_r, _c) a normal ledge? (wraps around sideways, like the tower)
    var _is_ledge = function(_m, _r, _c, _n)
    {
        var _ch = string_char_at(_m[_r], ((_c mod _n) + _n) mod _n + 1);
        return _ch == "=" || _ch == "S";
    };

    for (var r = 0; r < _rows; r++)
    {
        var _line = _map[r];
        for (var c = 0; c < _cols; c++)
        {
            var _ch = string_char_at(_line, c + 1);
            var _x  = c * _ts, _y = r * _ts;
            switch (_ch)
            {
                case "=":
                case "S":
                {
                    if (_ch == "S") instance_create_depth(_x + _ts / 2, _y, 0, obj_plat_start);
                    if (!_paint_tiles) break;
                    // ends get the capped tiles
                    var _l  = _is_ledge(_map, r, c - 1, _cols);
                    var _rt = _is_ledge(_map, r, c + 1, _cols);
                    tilemap_set(_ledge, (!_l && _rt) ? 6 : ((_l && !_rt) ? 8 : 7), c, r);
                }
                break;

                case "C":   // a run of C's is one crumbling ledge
                    if (c == 0 || string_char_at(_line, c) != "C")
                    {
                        var _n = 0;
                        while (c + _n < _cols && string_char_at(_line, c + _n + 1) == "C") _n++;
                        with (instance_create_depth(_x, _y, -50, obj_plat_crumble)) setup(_n);
                    }
                break;

                case "O":
                    instance_create_depth(_x + _ts / 2, _y + _ts / 2, -130, obj_plat_orbit);
                break;

                case "Q":
                    with (instance_create_depth(_x + _ts / 2, _y + _ts / 2, -130, obj_plat_orbit))
                    {
                        count  = round(lerp(5, 8, diff));
                        radius = 185;
                        spd    = -lerp(0.7, 1.3, diff);
                    }
                break;

                case "F":
                    with (instance_create_depth(_x + _ts / 2, _y, 0, obj_plat_fishlane)) floor_y = (r + 1) * _ts;
                break;

                case "R":
                    instance_create_depth(_x + _ts / 2, _y, -135, obj_plat_rubble);
                break;

                case "W":
                    instance_create_depth(_x + _ts / 2, _y, 0, obj_plat_wind);
                break;
            }
        }
    }
}