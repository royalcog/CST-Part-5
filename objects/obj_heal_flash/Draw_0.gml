if (!instance_exists(target)) exit;

// pulses a few times and fades out over the duration
var _pulse = 0.5 + 0.5 * sin(timer * 0.3);
var _alpha = _pulse * 0.8 * (1 - timer / duration);

gpu_set_fog(true, flash_color, 0, 0);
draw_sprite_ext(target.sprite_index, target.image_index, target.x, target.y,
                target.image_xscale, target.image_yscale, target.image_angle, c_white, _alpha);
gpu_set_fog(false, c_black, 0, 0);