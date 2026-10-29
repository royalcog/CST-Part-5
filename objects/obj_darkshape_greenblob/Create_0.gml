// COURAGE (Deltarune's obj_darkshape_greenblob). born white, it pops away from the SOUL, shrinks and turns
// yellow, then homes in, harder the closer it is. touch it for TP. (DR's numbers at 30fps, converted)
size        = 2;                       // Deltarune's in the Titan Spawn fight
tp_gain     = size * 2 / 250 * 100;    // 1.6%...
if (instance_exists(obj_battle_menu) && obj_battle_menu.turn >= 4) tp_gain *= 2;   // ...doubled from turn 4
pickup_r    = 20;
friction    = 0.922;   // DR 0.85
max_speed   = 2.5;     // DR 5
acc         = 5;       // DR 20: speeds up by acc / distance a frame
prime_speed = 2;       // DR 4: how hard it pops away from the SOUL
prime_time  = 40;      // DR 20: frames to shrink + turn yellow before it homes in
size_to     = 0.6;     // DR's size for these

state = "new";         // priming -> active. "orb": a fish's grey orb (the fish carries it)
scale = 1;  scale_from = 1;
col   = c_white;  col_from = c_white;
spd = 0;  dir = 0;  t = 0;  f = 0;
collected = false;
ring = 0;
fading = false;
image_alpha = 1;

/// pops away from the SOUL, shrinking and turning yellow, then homes in
prime = function()
{
    state = "priming";
    t = 0;
    scale_from = scale;
    col_from   = col;
    dir = instance_exists(obj_soul) ? point_direction(obj_soul.x, obj_soul.y, x, y) : random(360);
    spd = prime_speed;
}
/// a fish piece that's been purified: a grey orb, full size, carried along by the fish until its head goes
orb = function()
{
    state = "orb";
    scale = 1;
    col   = make_color_rgb(128, 128, 128);
}
prime();