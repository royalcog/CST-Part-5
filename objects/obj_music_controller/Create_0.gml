if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}

global.song = noone;
global.music = noone;

global.beat = 0;
global.offset = 0;
global.song_start = current_time;

global.tracked_loops = [];   // NEW: list of {instance, loop_start, loop_end} to auto-loop

persistent = true;