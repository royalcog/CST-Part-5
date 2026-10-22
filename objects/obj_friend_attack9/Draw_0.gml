if (phase == "tear")
{
    var _fade = 1 - clamp(timer / tear_duration, 0, 1); // fades out as it finishes separating
    var _half_w = tear_raw_w / 2;

    draw_sprite_part_ext(
        tear_sprite, tear_image_index,
        0, 0, _half_w, tear_raw_h,
        tear_base_x - tear_split, tear_base_y,
        tear_xscale, tear_yscale,
        c_white, _fade
    );

    draw_sprite_part_ext(
        tear_sprite, tear_image_index,
        _half_w, 0, tear_raw_w - _half_w, tear_raw_h,
        tear_base_x + _half_w * tear_xscale + tear_split, tear_base_y,
        tear_xscale, tear_yscale,
        c_white, _fade
    );
}