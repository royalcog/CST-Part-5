anim[0] += 0.5;
anim[10] += 20;
if (talking)
{
    talk_ind += 0.25;
    if (talk_ind > 3) talk_ind = 0;
    anim[1] += sin(anim[0] - 90) * 0.1;
    if (anim[0] > 150) anim[0] = 0;
}
else
{
    talk_ind = 0;
    anim[1] += (0 - anim[1]) * 0.02;
}
anim[2] = cos(anim[10] / 200) * 2;
anim[3] = sin(100 + (anim[10] / 400)) - cos(anim[10] / 200);
anim[7] += (0 - anim[7]) * 0.1;
anim[8] = 22 + (-22 * (1 - anim[7]));

scr_char_jolt_update(self);