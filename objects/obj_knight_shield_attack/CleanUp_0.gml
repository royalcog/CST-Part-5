// Ralsei never gets stuck mid-spell
if (instance_exists(obj_ralsei) && scr_party_is_up(obj_ralsei)
    && (obj_ralsei.sprite_index == ralsei_cast_sprite || obj_ralsei.sprite_index == spr_ralsei_spellready))
{
    scr_set_battle_sprite(obj_ralsei, ralsei_idle_sprite, noone, true);
}