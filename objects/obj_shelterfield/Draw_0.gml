var scale = max(853 / 320, 480 / 172);

draw_sprite_ext(
    spr_shelterfield,
    0,
    room_width / 2,
    room_height / 2,
    scale,
    scale,
    0,
    c_white,
    1
);
