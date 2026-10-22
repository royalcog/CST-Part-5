if (!variable_instance_exists(id, "side")) side = "left";
if (!variable_instance_exists(id, "gap_half")) gap_half = 20;
if (!variable_instance_exists(id, "hold_time")) hold_time = 45;

move_speed = 14;
hand_scale = 1.1;
sprite_index = spr_friend_hand_paper;
image_xscale = hand_scale;
image_yscale = hand_scale;
already_hit = false;
depth = -380;

// spawn position uses the box's CURRENT interior (where it looks right now)
var _interior = scr_get_box_interior();

// but the hands should aim at where the box will actually END UP,
// not where it currently is mid-lerp — so target_val is built from
// the box's future (target-scale) interior instead
var _future = scr_get_box_interior(true);
var _fcx = lerp(_future.x1, _future.x2, 0.5);
var _fcy = lerp(_future.y1, _future.y2, 0.5);

switch (side)
{
    case "left":
        x = _interior.x1 - 250; y = _fcy;
        start_val = x; target_val = _fcx - gap_half;
        image_angle = 0;
    break;
    case "right":
        x = _interior.x2 + 250; y = _fcy;
        start_val = x; target_val = _fcx + gap_half;
        image_angle = 180;
    break;
    case "up":
        x = _fcx; y = _interior.y1 - 250;
        start_val = y; target_val = _fcy - gap_half;
        image_angle = 270;
    break;
    case "down":
        x = _fcx; y = _interior.y2 + 250;
        start_val = y; target_val = _fcy + gap_half;
        image_angle = 90;
    break;
}
draw_angle = image_angle;

phase = "in";
hold_timer = 0;