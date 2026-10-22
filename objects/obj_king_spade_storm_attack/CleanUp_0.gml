// if this gets cut short, don't leave a frozen beam sitting in the box or the box stuck tilted
for (var i = 0; i < array_length(beam); i++)
{
    if (instance_exists(beam[i].inst)) beam[i].inst.fading_out = true;
}
if (instance_exists(obj_battlebox)) obj_battlebox.box_angle = 0;