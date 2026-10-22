// whatever happens (normal end, party wipe), later rounds go back to the soul they had
global.soul_mode = saved_mode;
if (shake_snd != -1) audio_stop_sound(shake_snd);
knight_restore(); // never leave them stuck mid-swing