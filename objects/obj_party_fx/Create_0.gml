// a party member's FIGHT, for the ones who don't swing at it: Pink's bomb, Jevil's spade, Spamton's pipis.
// obj_battle_menu makes it the moment their bolt's hit, and does the damage once hit goes true
kind          = "bomb";    // "bomb" / "spade" / "pipis"
owner         = noone;     // who's attacking (their object)
target        = noone;     // the battle target (its x/y is where they aim: the Titan's chest)
release_frame = 0;         // (the bomb) the frame of her throw it leaves her hand on
hit           = false;
state         = "wait";
t             = 0;
depth         = -3000;

// --- tuning ---
bomb_hand   = { x: 34, y: -118 };   // where it leaves Pink's hand, from her origin (facing right)
bomb_time   = 32;       // frames it's in the air
bomb_arc    = 120;      // px high its arc goes
bomb_scale  = 2;
bomb_spin   = 14;       // degrees a frame
boom_scale  = 4;        // spr_pinkbomb_explosion's tiny (24px)
spade_at    = { x: 70, y: -70 };    // where Jevil's spade appears, from his origin (facing right)
spade_grow  = 20;       // frames it takes to appear
spade_hover = 16;       // frames it hangs there spinning
spade_speed = 18;       // px a frame
spade_scale = 1.5;
face_dy     = -100;     // the Titan's face, from where it's aimed at (its chest)
pipis_n     = 3;        // pipis Spamton drops...
pipis_gap   = 10;       // ...this many frames apart...
pipis_from  = 260;      // ...from this far above its face
pipis_grav  = 0.6;
pipis_scale = 3;

// --- state ---
px = 0; py = 0; sx = 0; sy = 0; tx = 0; ty = 0;
rot = 0; scale = 0;
pipis = [];
booms = [];   // { spr, x, y, f, fspd, s, ang }
bits  = [];   // the spade's chunks

add_boom = function(_spr, _x, _y, _fspd, _s)
{
    array_push(booms, { spr: _spr, x: _x, y: _y, f: 0, fspd: _fspd, s: _s, ang: irandom(360) });
}
/// where it's going
aim = function()
{
    if (instance_exists(target)) return { x: target.x, y: target.y };
    return { x: camera_get_view_x(view_camera[0]) + 700, y: camera_get_view_y(view_camera[0]) + 200 };
}