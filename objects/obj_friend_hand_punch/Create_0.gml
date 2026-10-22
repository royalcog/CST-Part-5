if (!variable_instance_exists(id, "side")) side = "left";
if (!variable_instance_exists(id, "start_override")) start_override = undefined;
if (!variable_instance_exists(id, "speed_override")) speed_override = undefined;

move_speed = is_undefined(speed_override) ? 18 : speed_override;
hand_scale = 1.1;
sprite_index = spr_friend_hand_rock;
image_xscale = hand_scale;
image_yscale = hand_scale;
already_hit = false;
depth = -380;

var _interior = scr_get_attack_bounds();
var _cx = lerp(_interior.x1, _interior.x2, 0.5);
var _cy = lerp(_interior.y1, _interior.y2, 0.5);
var _perp = variable_instance_exists(id, "fixed_coord") ? fixed_coord : undefined;

switch (side)
{
    case "left":
        y = is_undefined(_perp) ? _cy : _perp;
        x = is_undefined(start_override) ? (_interior.x1 - 250) : start_override;
        target_val = _interior.x2 + 250;
    break;
    case "right":
        y = is_undefined(_perp) ? _cy : _perp;
        x = is_undefined(start_override) ? (_interior.x2 + 250) : start_override;
        target_val = _interior.x1 - 250;
    break;
    case "up":
        x = is_undefined(_perp) ? _cx : _perp;
        y = is_undefined(start_override) ? (_interior.y1 - 250) : start_override;
        target_val = _interior.y2 + 250;
    break;
    case "down":
        x = is_undefined(_perp) ? _cx : _perp;
        y = is_undefined(start_override) ? (_interior.y2 + 250) : start_override;
        target_val = _interior.y1 - 250;
    break;
}

switch (side)
{
    case "left":  image_angle = 0;   break; 
    case "right": image_angle = 180; break; 
    case "down":  image_angle = 90;  break; 
    case "up":    image_angle = 270; break; 
}
draw_angle = image_angle; 

start_val = (side == "left" || side == "right") ? x : y;
progress = 0;