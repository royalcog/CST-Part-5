/// returns { box, downed, swoon_popup }
function scr_party_damage(_amount)
{
    var _result = { box: noone, downed: false, swoon_popup: false };

    var _candidates = [];
    with (obj_battle_ui_box)
    {
        if (hp > 0) array_push(_candidates, id);
    }
    if (array_length(_candidates) == 0) return _result; // whole party's down

    var _target = _candidates[irandom(array_length(_candidates) - 1)];
    _result.box = _target;
	
    // Queen's DEFEND shield takes it instead
    if (_target.char_name == "Queen" && scr_queen_shield_up())
    {
        obj_queen_shield.hit(_amount);
        return _result;
    }

    // the Knight's hits swoon outright
    var _knight_rules = instance_exists(obj_king_turn_sequencer) && obj_king_turn_sequencer.swoon_kills;

    with (_target)
    {
        // DEFENDing (the battle menu) takes a third off
        if (variable_instance_exists(id, "defending") && defending) _amount = ceil(_amount * 2 / 3);
        hp -= _amount;
        hurt_timer = hurt_flash_time;

        if (hp <= 0)
        {
            _result.downed = true;
            if (_knight_rules)
            {
                hp = -999;
                _result.swoon_popup = true;
            }
            scr_party_body_down();
        }
        else
        {
            scr_party_body_hurt();
        }
    }

    if (_result.swoon_popup) scr_party_swoon_popup(_target);
    return _result;
}

// runs from inside an obj_battle_ui_box
function scr_party_body_hurt()
{
    if (body == noone || body_hurt_sprite == -1) exit;

    var _inst = instance_find(body, 0);
    if (!instance_exists(_inst)) exit;

    // only save the pose if they're not already mid-hurt, so a second hit
    // doesn't save the hurt sprite as the one to go back to
    if (body_hurt_timer <= 0)
    {
        body_inst = _inst;
        body_saved = {
            sprite: _inst.sprite_index,
            index:  _inst.image_index,
            spd:    _inst.image_speed,
            loop:   _inst.anim_loop,
            x:      _inst.x
        };
    }

    with (_inst)
    {
        sprite_index = other.body_hurt_sprite;
        image_index = 0;
        image_speed = 0;
    }

    body_hurt_timer = body_hurt_time;
}

// runs from inside an obj_battle_ui_box: drops the character into their swooned sprite, feet planted
function scr_party_body_down()
{
    // cancel a hurt pose in progress so it doesn't swap them back up when it ends
    if (body_hurt_timer > 0 && instance_exists(body_inst)) body_inst.x = body_saved.x;
    body_hurt_timer = 0;

    if (body == noone || body_down_sprite == -1) exit;
    var _inst = instance_find(body, 0);
    if (!instance_exists(_inst)) exit;

    scr_set_battle_sprite(_inst, body_down_sprite, body_down_sprite, false);
}

/// gets a downed character back up with 1/6 of their max HP, back in battle idle. returns the HP they came back with
function scr_party_revive(_box)
{
    var _amount = ceil(_box.max_hp / 6);
    with (_box)
    {
        hp = _amount;
        if (body != noone && body_idle_sprite != -1)
        {
            var _inst = instance_find(body, 0);
            if (instance_exists(_inst)) scr_set_battle_sprite(_inst, body_idle_sprite, body_idle_sprite, true);
        }
    }
    return _amount;
}

/// start of every party turn: anyone down gets 1/8 of their max back, and revives once that puts them above 0.
/// each heal pops up green over their head; snd_heal plays once no matter how many healed
function scr_party_turn_recover(_color = make_color_rgb(0, 255, 0))
{
    var _healed = false;
    with (obj_battle_ui_box)
    {
        if (hp > 0) continue;

        var _heal = ceil(max_hp / 8);
        hp += _heal;
        if (hp > 0) _heal = scr_party_revive(id); // swaps to idle first, so the number sits over their standing head

        scr_party_head_popup(id, _heal, _color, noone);
        _healed = true;
    }
    if (_healed) audio_play_sound(snd_heal, 5, false);
}

/// a popup (number or text) just above the top of a party member's head
function scr_party_head_popup(_box, _text, _color, _sound = snd_hurt, _life = 30)
{
    if (_box.body == noone) return noone;
    var _inst = instance_find(_box.body, 0);
    if (!instance_exists(_inst)) return noone;

    var _spr = _inst.sprite_index;
    var _hx  = _inst.x + ((sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr) + 1) / 2 - sprite_get_xoffset(_spr)) * _inst.image_xscale;
    var _hy  = _inst.y + (sprite_get_bbox_top(_spr) - sprite_get_yoffset(_spr)) * _inst.image_yscale - 6;

    var _p = scr_trigger_damage_popup(_inst, _text, _color, _color, _hx - _inst.x, _hy - _inst.y, _sound);
    if (_p != noone) _p.life = _life;
    return _p;
}

/// "SWOON" popping up over the top of a character's head
function scr_party_swoon_popup(_box, _color = c_red)
{
    return scr_party_head_popup(_box, "SWOON", _color, snd_hurt, 60);
}

/// true unless this character is swooned (also true if they're not in the party at all)
function scr_party_is_up(_obj)
{
    var _up = true;
    with (obj_battle_ui_box)
    {
        if (body == _obj && hp <= 0) _up = false;
    }
    return _up;
}