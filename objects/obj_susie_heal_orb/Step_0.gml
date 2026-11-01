if (!instance_exists(target) || !instance_exists(box)) { instance_destroy(); exit; }

t++;
var _tx = (target.bbox_left + target.bbox_right) / 2;
var _ty = (target.bbox_top + target.bbox_bottom) / 2;

// curves round toward them, tighter every frame
turn += turn_acc;
var _want = point_direction(x, y, _tx, _ty);
var _d    = angle_difference(_want, dir);
dir += clamp(_d, -turn, turn);
spd = min(spd + spd_acc, spd_max);

array_push(trail, { x: x, y: y });
if (array_length(trail) > trail_len) array_delete(trail, 0, 1);

x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);

// there: heal them to full (back up if they were down)
if (point_distance(x, y, _tx, _ty) <= spd + 4 || t > 240)
{
    if (box.hp < box.max_hp) scr_bm_heal(box, box.max_hp - box.hp);
    var _f = instance_create_depth(0, 0, target.depth - 1, obj_heal_flash);
    _f.target   = target;
    _f.duration = 30;
    instance_destroy();
}