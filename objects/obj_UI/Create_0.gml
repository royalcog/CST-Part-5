use_party_boxes = false;
image_xscale = 1;
image_yscale = 1;
var _camx = camera_get_view_x(view_camera[0]);
var _camy = camera_get_view_y(view_camera[0]);
var _camw = camera_get_view_width(view_camera[0]);
var _camh = camera_get_view_height(view_camera[0]);
// total on-screen width of the party panel, once all three boxes are scaled to their target size
var _party_width = 231 + 235 + 248 + 8; // ≈ 722, using the new scaled widths above
var _right_nudge = 140; // shift the whole panel right of dead-center by this many px — adjust to taste
target_x = _camx + (_camw - _party_width) / 2 + _right_nudge;
x = _camx + _camw + sprite_width * image_xscale; // start off screen right
y = _camy + _camh - 10;

offscreen_x = x; // <-- remember this starting position so we can send it back later
onscreen_x = target_x; // remember the real onscreen position so we can return to it later

active_box = noone; // which obj_battle_ui_box currently shows its button row

boxes_x_correction = -90; // pulls just the boxes back left, independent of obj_UI's own anchor — tune this, not box_offset_x
boxes_y_correction = 3; // pushes just the boxes down, independent of obj_UI's own anchor — tune this, not box_offset_y

panel_full_width = false; // party-box mode: draw this panel stretched edge to edge behind the boxes

ui_hidden   = false; // true = panel + party boxes slide down off the bottom
hide_y      = 0;
hide_drop   = 200;   // how far down it slides when hidden
