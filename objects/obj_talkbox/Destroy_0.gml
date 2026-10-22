if instance_exists(obj_battat)
{
    obj_battat.talking = false;
}
if instance_exists(obj_jongler) { obj_jongler.talking = false; }
if instance_exists(obj_pluey) { obj_pluey.talking = false; }

if variable_instance_exists(id, "on_destroy_reveal") && on_destroy_reveal
{
    scr_reveal_mike_trio();
}