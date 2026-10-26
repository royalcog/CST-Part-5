// ---------------- set up (the first step, once whoever made it has set its mode) ----------------
if (!init)
{
    init = true;
    if (mode == "sea")
    {
        build_sea();
        if (!front)
        {
            // behind the floor (and, if sea_edges_front, a second one in front of it for the puffs touching its edges)
            var _lay = layer_exists(sea_layer) ? layer_get_id(sea_layer) : -1;
            var _d = (_lay != -1) ? layer_get_depth(_lay) : 0;
            depth = _d + 50;
            if (sea_edges_front) with (instance_create_depth(0, 0, _d - 1, obj_plat_cloud))
            {
                mode = "sea"; front = true; sea_layer = other.sea_layer;
                init = true;
                build_sea();
            }
        }
        exit;
    }

    build_rings();
    var _ctl = instance_find(obj_plat_controller, 0);
    if (global.plat_cloud.on && _ctl != noone)
    {
        if (entry_kind == "fall") hold = true;   // falling in from above: it comes back in once they've landed
        else cloud_y = _ctl.leader().y + max(global.plat_cloud.gap, min_gap);
    }
}

if (mode != "rise") exit;

var _ctl = instance_find(obj_plat_controller, 0);
if (_ctl == noone) exit;
var _ld = _ctl.leader();
if (!instance_exists(_ld)) exit;
var _playing = (_ctl.state == "play") && !instance_exists(obj_plat_battle);

// ---------------- it shows up once the halfway chat's over (with the first Titan Spawn) ----------------
if (!global.plat_cloud.on)
{
    if (_ctl.first_room && _playing && _ctl.spawn_on)
    {
        global.plat_cloud.on = true;
        cloud_y = _ld.y + arrive_gap;
        spd = 0;
    }
    else exit;
}

if (hold)
{
    if (_playing && _ld.grounded) { hold = false; cloud_y = _ld.y + arrive_gap; spd = 0; }
    else exit;
}

// ---------------- rising (Deltarune's speeds: slow right under you, faster the further ahead you are) ----------------
spd = max(spd - 0.2, -20);
var _dist = abs(cloud_y - _ld.y);
vspd = lerp(max(min_speed, spd), max_speed, clamp(_dist / 300, 0, 1));
if (_dist / 300 > 1.5 && max_speed != 0) vspd = min(vspd, catchup);
if (_playing) cloud_y += vspd;

// it caught you
if (_playing && hurt_on && _ld.invuln <= 0 && _ld.y > cloud_y + hurt_dist)
{
    _ld.take_hit(_ld.x, irandom_range(damage_min, damage_max));
    spd = push_back;
}

global.plat_cloud.gap = cloud_y - _ld.y;   // so the next room puts it the same distance under them

// ---------------- the rings: spin, and tip into an oval when the cloud's away from the middle of the screen ----------------
var _center_y = camera_get_view_y(view_camera[0]) + 200;
var _cd = clamp((cloud_y - _center_y) / 340, -1, 1);
y_scale = sin(abs(_cd) * pi / 2) * sign(_cd) * 0.2;
cloud_angle += spin_speed;

for (var i = 0; i < array_length(clouds); i++)
{
    var _c = clouds[i];
    _c.angle = _c.base_angle + cloud_angle;
    var _d = ring_dr[_c.ring];
    _c.z = ((abs(angle_difference(_c.angle, -90)) / 180) * 2 - 1) * _d;   // < 0 = the front half
    _c.x = lengthdir_x(1, _c.angle) * ring_r[_c.ring];
    _c.y = lengthdir_y(1, _c.angle) * y_scale * tilt * _d;
}
array_sort(clouds, function(_a, _b) { return sign(_b.z - _a.z); });   // furthest first