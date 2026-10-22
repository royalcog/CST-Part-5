anim[0] += 0.25;
anim[10] += 20;
if (talking)
{
    anim[5] = min(anim[5], 60);
    anim[1] += (sin(anim[0] / 20) * 3 - anim[1]) * 0.05;
    if (anim[0] > 260) anim[0] = 0;
}
else
{
    anim[1] += (0 - anim[1]) * 0.1;
}
anim[2] = cos(anim[10] / 200) * 2;
anim[3] = sin(100 + (anim[10] / 400)) - cos(anim[10] / 200);
anim[7] += (0 - anim[7]) * 0.1;
anim[8] = 43 + (-43 * (1 - anim[7]));