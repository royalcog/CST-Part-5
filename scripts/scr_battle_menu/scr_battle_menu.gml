// the player-run battle menu (obj_battle_menu): who has what, the spells/ACTs/items, and the effects.
// numbers here are all tuning, change them freely.

/// what each party member can do. _name: "Susie" / "Ralsei" / "Queen" (the obj_battle_ui_box char_name)
/// at: their attack (FIGHT damage is Deltarune's: round(at * points / 20) - enemy df * 3, points 0-150)
/// poses: ready_* = held once they've picked (before it happens), *_anim = played when it happens.
///        "defend" for Queen is her shield (obj_queen_shield), not a sprite
function scr_bm_member_def(_name)
{
    switch (_name)
    {
        case "Susie": return {
            obj: obj_susie, color: make_color_rgb(255, 0, 255),
            cmds: ["FIGHT", "MAGIC", "ITEM", "SPARE", "DEFEND"],
            at: 20, mg: 3,
            idle: spr_susie_battle_idle, idle_hold: false,
            ready_fight: spr_susie_attack_ready, ready_magic: spr_susie_attack_ready, ready_act: -1,
            ready_item: spr_susie_itemready, item_anim: spr_susie_item,
            defend: spr_susie_defend,
            attack: spr_susie_battle_intro, attack_sound_frame: 0,
            spell_anim: spr_susie_heal,                       // for Heal (Rude Buster has its own swing)
            magic: [
                // Rude Buster: Deltarune's at * 11 + mg * 5 (halved against the Titan Spawn, like the game)
                { name: "Rude Buster", tp: 50, target: "enemy", effect: "rudebuster", amount: 0,
                  desc: "Rude\nDamage" },
                { name: "Heal",        tp: 75, target: "ally",  effect: "heal",       amount: 60,
                  desc: "Heal\nAlly" },
                { name: "Scythemare",  tp: 40, target: "none",  effect: "scythemare", amount: 0,
                  desc: "Spare all\nTIRED foes" },      // Scythemare
            ],
        };
        case "Ralsei": return {
            obj: obj_ralsei, color: make_color_rgb(1, 255, 0),
            cmds: ["FIGHT", "MAGIC", "ITEM", "SPARE", "DEFEND"],
            at: 13, mg: 11,
            idle: spr_ralsei_battle_idle, idle_hold: false,
            ready_fight: spr_ralsei_attack_ready, ready_magic: spr_ralsei_spellready, ready_act: -1,
            ready_item: spr_ralsei_itemready, item_anim: spr_ralsei_item,
            defend: spr_ralsei_defend,
            attack: spr_ralsei_attack, attack_sound_frame: 4,
            spell_anim: spr_ralsei_spell,
            magic: [
                { name: "Pacify",      tp: 16, target: "enemy", effect: "pacify",     amount: 0,
                  desc: "Spare\nTIRED foe" },
                { name: "Heal Prayer", tp: 32, target: "ally",  effect: "heal",       amount: 75,
                  desc: "Heal\nAlly" },
                { name: "ReviveSong",  tp: 84, target: "ally",  effect: "revivesong", amount: 120,
                  desc: "Revive\nAlly" },               // ReviveSong
            ],
        };
        case "Queen": return {
            obj: obj_queen, color: make_color_rgb(111, 209, 255),
            cmds: ["FIGHT", "ACT", "ITEM", "SPARE", "DEFEND"],
            at: 14, mg: 0,
            idle: spr_queen_walk_right_unhappy, idle_hold: true,
            ready_fight: spr_queen_pie_throw, ready_magic: -1, ready_act: spr_queen_pointright,
            ready_item: spr_queen_wine_right_unhappy, item_anim: spr_queen_wine_right_unhappy,
            ready_hold: true,                                 // her ready poses hold still (first frame)
            defend: "shield",
            attack: spr_queen_pie_throw, attack_sound_frame: 2,
            spell_anim: spr_queen_pointright,                 // her ACTs
            magic: [   // her ACTs
                { name: "Check",   tp: 0, target: "enemy", effect: "check",   amount: 0,
                  desc: "" },     // Deltarune's ACTs don't have a description
                { name: "Lecture", tp: 0, target: "none",  effect: "lecture", amount: 10,
                  desc: "Raises TP\n10%" },
            ],
        };
    }
    return undefined;
}

/// the shared inventory for this battle (Deltarune items). used ones are gone for good
function scr_bm_items_default()
{
    return [
        { name: "Dark Candy",  target: "ally", effect: "heal",   amount: 40,  desc: "Heals\n40HP" },
        { name: "Dark Candy",  target: "ally", effect: "heal",   amount: 40,  desc: "Heals\n40HP" },
        { name: "Darkburger",  target: "ally", effect: "heal",   amount: 70,  desc: "Heals\n70HP" },
        { name: "TensionBit",  target: "none", effect: "tp",     amount: 32,  desc: "Raises TP\n32%" },
        { name: "ReviveMint",  target: "ally", effect: "revive", amount: 0,   desc: "Heal Downed\nAlly" },
    ];
}

/// heals a party box by _amt (gets them back up if that puts them above 0). green number over their head
function scr_bm_heal(_box, _amt)
{
    var _was_down = _box.hp <= 0;
    var _new = min(_box.max_hp, _box.hp + _amt);
    if (_was_down && _new > 0)
    {
        scr_party_revive(_box);   // back to battle idle
        _box.hp = _new;
    }
    else _box.hp = _new;
    scr_party_head_popup(_box, _amt, make_color_rgb(0, 255, 0), noone);
    audio_play_sound(snd_heal, 5, false);
}

/// puts a party member's body in a pose. every battle sprite's origin is lined up with their idle's feet,
/// so it's a straight swap (no re-anchoring).
/// _mode: 0 (or false) = hold its first frame, 1 (or true) = play once and hold the last frame, 2 = loop it
function scr_bm_pose(_obj, _spr, _mode = 0)
{
    if (!is_real(_spr) || _spr == -1 || !instance_exists(_obj)) return;
    with (_obj)
    {
        sprite_index = _spr;
        last_sprite  = _spr;
        image_index  = 0;
        image_speed  = (_mode == 0) ? 0 : 1;
        anim_loop    = (_mode != 1);
    }
}

/// back to battle idle
function scr_bm_idle(_def)
{
    if (!instance_exists(_def.obj)) return;
    with (_def.obj) { sprite_index = _def.idle; last_sprite = _def.idle; image_index = 0; image_speed = _def.idle_hold ? 0 : 1; anim_loop = true; }
}