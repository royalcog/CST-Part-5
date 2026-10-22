if (!instance_exists(obj_battlebox) || obj_battlebox.state == "closing") { instance_destroy(); exit; }

t++;
active = (t < hold);
if (t < fade_in)   alpha = t / fade_in;
else if (active)   alpha = 1;
else               alpha = 1 - (t - hold) / fade_out;

if (t >= hold + fade_out) instance_destroy();