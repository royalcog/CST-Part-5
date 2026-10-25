// made on the first step (floor_y is set just after this object's made), and again if anything ever clears it
if (!instance_exists(fish))
{
    fish = instance_create_depth(0, 0, -140, obj_plat_titanfish);
    fish.arena = { cx: 0 };
    fish.loop  = true;
    fish.dir   = dir;
    fish.spd   = fish_spd;
    fish.scale = scale;
    fish.y0    = floor_y - (sprite_get_height(spr_titanfish_body) / 2) * scale - 2;
    fish.ox    = random(room_width);
}