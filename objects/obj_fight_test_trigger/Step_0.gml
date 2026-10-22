// obj_fight_test_trigger — Step event
if (!started && variable_global_exists("atk_sound_of_justice_hammers"))
{
    started = true;
    var pink = obj_mewmew;
    var _seq = instance_create_depth(0, 0, 0, obj_fight_sequencer);
    _seq.sequence = [
        { type: "talk", batch: [ { speaker: pink, text: "Your first line here..." } ] },
        { type: "attack", attacker: obj_sound_of_justice, data: global.atk_sound_of_justice_hammers },
        { type: "talk", batch: [ { speaker: pink, text: "e" } ] },
        { type: "attack", attacker: obj_sound_of_justice, data: global.atk_sound_of_justice_hammers }
    ];
}