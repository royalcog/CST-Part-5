if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

// count down warnings, launch any wall whose warning just finished
var _launched = false;
for (var i = array_length(pending) - 1; i >= 0; i--)
{
    pending[i].timer--;
    if (pending[i].timer <= 0)
    {
        launch_wall(pending[i]);
        array_delete(pending, i, 1);
        _launched = true;
    }
}
if (_launched && spawn_sound != -1) audio_play_sound(spawn_sound, 5, false);

switch (state)
{
    case "walls":
        timer--;
        if (timer > 0) break;

        var _w;
        do
        {
            _w = walls[wall_index];
            plan_wall(_w);
            wall_index++;
        }
        until (!(variable_struct_exists(_w, "with_next") && _w.with_next) || wall_index >= array_length(walls));

        if (wall_index >= array_length(walls))
        {
            timer = warn_frames + end_delay; // let the last warning play out before counting down
            state = "end_hold";
        }
        else
        {
            timer = _w.wait;
        }
    break;

    case "end_hold":
        timer--;
        if (timer <= 0) instance_destroy();
    break;
}