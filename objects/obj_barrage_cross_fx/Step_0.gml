timer++;

var _cam = view_camera[0];
var _target_h = camera_get_view_width(_cam) * 2;
var _target_v = camera_get_view_height(_cam) * 2;

if (timer <= grow_time)
{
    var _t = timer / grow_time;
    len_h = lerp(0, _target_h, _t);
    len_v = lerp(0, _target_v, _t);
}
else if (timer <= grow_time + hold_time)
{
    len_h = _target_h;
    len_v = _target_v;
}
else if (timer <= grow_time + hold_time + fade_time)
{
    len_h = _target_h;
    len_v = _target_v;
    image_alpha = 1 - ((timer - grow_time - hold_time) / fade_time);
}
else
{
    instance_destroy();
}