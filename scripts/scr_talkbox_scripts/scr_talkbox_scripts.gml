function scr_talkbox_show(_speaker, _text, _wrap_w, _offx, _offy, _fp, _cps, _keep_speaker_animating = true, _dim_alpha = -1, _animate = true, _instant_cutoff = false)
{
    var inst = instance_create_layer(0, 0, "UI", obj_talkbox);
    with (inst) {
        speaker      = _speaker;
        quote        = _text;
        wrap_w       = _wrap_w;
        mouth_off_x  = _offx;
        mouth_off_y  = _offy;
        flip_talkbox = _fp;
        chars_per_s  = (is_real(_cps) ? _cps : 0);
        keep_speaker_animating = _keep_speaker_animating;
        dim_alpha = (_dim_alpha >= 0) ? _dim_alpha : global.default_talkbox_dim;
        animate_while_talking = _animate;
        instant_cutoff = _instant_cutoff;
        base_animating = (instance_exists(_speaker) && _speaker.image_speed > 0);
        switch (_speaker.char_id)
        {
            case CharID.Pink: speak_snd = snd_empty; snd_delay = 0; speak_vol = 0.7; break;
            case CharID.Friend: speak_snd = snd_empty; snd_delay = 0; speak_vol = 0.7; break;
            case CharID.Gerson: speak_snd = snd_gerson; snd_delay = 0; speak_vol = 0.7; break;
            case CharID.Spamton: speak_snd = snd_spamton; snd_delay = 0; speak_vol = 0.7; break;
            case CharID.Jevil: speak_snd = snd_jevil; snd_delay = 0; speak_vol = 0.7; break;
            case CharID.Susie: speak_snd = snd_susie; snd_delay = 0; speak_vol = 0.7; break;
            case CharID.King: speak_snd = snd_king; snd_delay = 0; speak_vol = 0.7; break;
            case CharID.Queen: speak_snd = snd_queen; snd_delay = 0; speak_vol = 0.7; break;
            case CharID.Ralsei: speak_snd = snd_ralsei; snd_delay = 0; speak_vol = 0.7; break;
            default:          speak_snd = noone; speak_vol = 0.7;             break;
        }
        _recalc_layout();
    }
    return inst;
}

/// scr_dialogue_chain_interrupt()
/// Force-stops whatever battle dialogue is currently playing, instantly — mid-typing,
/// mid-hold, doesn't matter. Use this when something needs to cut a line off before it
/// finishes naturally (e.g. Lancer walking in on King mid-sentence). Destroys the current
/// obj_talkbox (if any) and the obj_dialogue_chain driving it, so nothing tries to continue
/// on to the next queued line afterward.
function scr_dialogue_chain_interrupt()
{
    if (instance_exists(obj_talkbox))
    {
        with (obj_talkbox) instance_destroy();
    }
    if (instance_exists(obj_dialogue_chain))
    {
        with (obj_dialogue_chain) instance_destroy();
    }
}