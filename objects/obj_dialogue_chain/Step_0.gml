if (dim_phase == 1) // first time — kick off the current batch
{
    entries = batches[batch_index];
    index = 0;
    next_delay = 0;
    dim_phase = 2;
}

if (dim_phase == 2) // run dialogue
{
    if (!instance_exists(curr_box))
    {
        if (next_delay > 0)
        {
            next_delay--;
        }
        else if (index < array_length(entries))
        {
            var e = entries[index];

            if (variable_struct_exists(e, "run"))
            {
                // run once, then optionally hold here until wait_until() says go
                if (!run_done)
                {
                    e.run();
                    run_done = true;
                }
                if (variable_struct_exists(e, "wait_until") && !e.wait_until()) exit;

                run_done = false;
                index += 1;
                next_delay = variable_struct_exists(e, "wait") ? e.wait : 0;
            }
            else
            {
                var sp  = e.speaker;
                var txt = e.text;

                // defensive: skip gracefully instead of a hard crash if the speaker
                // somehow doesn't exist (e.g. destroyed, or not present in this room)
                if (!instance_exists(sp))
                {
                    show_debug_message("obj_dialogue_chain: skipping line, speaker doesn't exist: " + txt);
                    index += 1;
                    next_delay = 0;
                    exit;
                }

                var ww = (variable_struct_exists(e, "wrap") ? e.wrap : default_wrap);
				var cid = sp.char_id;
				var ox  = offx[cid] + (variable_instance_exists(sp, "talk_nudge_x") ? sp.talk_nudge_x : 0);
				var oy  = offy[cid] + (variable_instance_exists(sp, "talk_nudge_y") ? sp.talk_nudge_y : 0);
				var fp  = flip[cid];
				var cps = variable_struct_exists(e, "cps") ? e.cps : default_cps;
				var _keep_anim = !(variable_struct_exists(e, "keep_animating") && !e.keep_animating);
				var _dim = variable_struct_exists(e, "dim") ? e.dim : -1;
				var _animate = !(variable_struct_exists(e, "no_animate") && e.no_animate);
				// instant_cutoff: this line advances the moment it finishes typing — no hold, and no
				// pause before the next line starts either (goes "instantly" to the next speaker)
				var _instant = variable_struct_exists(e, "instant_cutoff") && e.instant_cutoff;
				curr_box = scr_talkbox_show(sp, txt, ww, ox, oy, fp, cps, _keep_anim, _dim, _animate, _instant);
				if (variable_struct_exists(e, "snd") && e.snd != noone)
				{
				    audio_play_sound(e.snd, 1, false);
				}
				if (variable_struct_exists(e, "reveal") && e.reveal)
				{
				    curr_box.on_destroy_reveal = true;
				}
				index += 1;
				next_delay = _instant ? 0 : 60;
            }
        }
        else
        {
            batch_index++;
            if (batch_index < array_length(batches))
            {
                dim_phase = 1;
            }
            else
            {
                instance_destroy();
            }
        }
    }
}