/// call in a character's End Step: when sprite_index changes, shift x/y so the
/// new sprite's bottom-center lands where the old sprite's bottom-center was
/// sprites listed in the instance's keep_feet_skip array are trusted to have
/// hand-aligned origins and swap without any nudge
function scr_auto_keep_feet()
{
    if (!variable_instance_exists(id, "last_sprite") || last_sprite == noone)
    {
        last_sprite = sprite_index;
        exit;
    }
    if (sprite_index == last_sprite) exit;

    // origin-aligned sprites (e.g. asymmetric poses): just swap, don't re-anchor
    if (variable_instance_exists(id, "keep_feet_skip")
    && (array_contains(keep_feet_skip, sprite_index) || array_contains(keep_feet_skip, last_sprite)))
    {
        last_sprite = sprite_index;
        exit;
    }

    // where the feet were on the old sprite
    var _fx = x + (sprite_get_width(last_sprite) / 2 - sprite_get_xoffset(last_sprite)) * image_xscale;
    var _fy = y + (sprite_get_height(last_sprite) - sprite_get_yoffset(last_sprite)) * image_yscale;

    // where x/y needs to be for the new sprite's feet to land there
    var _nx = _fx - (sprite_get_width(sprite_index) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale;
    var _ny = _fy - (sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index)) * image_yscale;

    // keep an in-progress jolt centered on the new position
    if (variable_instance_exists(id, "jolt_start_x")) jolt_start_x += _nx - x;

    x = _nx;
    y = _ny;
    last_sprite = sprite_index;
}