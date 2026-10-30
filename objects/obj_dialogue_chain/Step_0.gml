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
				// which way they're facing: their usual bubble direction (flip), the other way if their sprite's mirrored
				var _mirrored = (sp.image_xscale < 0);
				var _face = (fp ? 1 : -1) * (_mirrored ? -1 : 1);
				if (auto_mouth)
				{
					// a set distance in front of their mouth (their sprite's top and how tall it is, the side they face)
					var _spr = sp.sprite_index;
					var _xa  = sp.x + (sprite_get_bbox_left(_spr) - sprite_get_xoffset(_spr)) * sp.image_xscale;
					var _xb  = sp.x + (sprite_get_bbox_right(_spr) + 1 - sprite_get_xoffset(_spr)) * sp.image_xscale;
					var _top = sp.y + (sprite_get_bbox_top(_spr) - sprite_get_yoffset(_spr)) * sp.image_yscale;
					var _h   = (sprite_get_bbox_bottom(_spr) + 1 - sprite_get_bbox_top(_spr)) * abs(sp.image_yscale);
					var _cx  = (_xa + _xb) / 2, _hw = abs(_xb - _xa) / 2;
					ox = _cx + _face * (_hw * mouth_reach + mouth_gap) - sp.x;
					oy = _top + _h * mouth_height - sp.y;
				}
				else if (_mirrored) ox = -ox;   // their set offset, mirrored across them
				fp = (_face > 0);               // the bubble opens out the way they're facing
				// a line can override where its bubble goes (someone standing somewhere / facing a way they usually don't)
				if (variable_struct_exists(e, "offx")) ox = e.offx;
				if (variable_struct_exists(e, "offy")) oy = e.offy;
				if (variable_struct_exists(e, "flip")) fp = e.flip;
				var cps = variable_struct_exists(e, "cps") ? e.cps : default_cps;
				var _keep_anim = !(variable_struct_exists(e, "keep_animating") && !e.keep_animating);
				var _dim = variable_struct_exists(e, "dim") ? e.dim : -1;
				var _animate = !(variable_struct_exists(e, "no_animate") && e.no_animate);
				// instant_cutoff: this line advances the moment it finishes typing — no hold, and no
				// pause before the next line starts either (goes "instantly" to the next speaker)
				var _instant = variable_struct_exists(e, "instant_cutoff") && e.instant_cutoff;
				curr_box = scr_talkbox_show(sp, txt, ww, ox, oy, fp, cps, _keep_anim, _dim, _animate, _instant);
				// (the talkbox always nudges its tip 20px left and 40px up, for the old fixed offsets: not wanted here)
				if (auto_mouth) { curr_box.triangle_xoff = 0; curr_box.triangle_yoff = 0; }
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