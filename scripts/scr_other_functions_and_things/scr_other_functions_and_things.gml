function queue_move(_obj, _target_x, _speed)
{
    var _entry = {obj: _obj, target_x: _target_x, speed: _speed};
    ds_queue_enqueue(global.move_queue, _entry);
}

function scr_tenna_shake(on_off)
{
    with (obj_tenna)
    {
        if (on_off)
        {
            active = 1;
            nowx = x;
            nowy = y;
            shakeamt = 3;
            timer = 0;
            on = 1;
        }
        else
        {
            active = 0;
            x = nowx;
        }
    }
}

function scr_tenna_ripple(_skip_draw)
{
    if (active == 0)
    {
        if !_skip_draw draw_self();
        exit;
    }
    
    siner++;
    image_angle = sin(siner * wobblespeed) * wobbleamount;
    
    if !_skip_draw
    {
        draw_sprite_ext(sprite_index, image_index,
            x + irandom_range(-jitteramount, jitteramount),
            y + irandom_range(-jitteramount, jitteramount),
            image_xscale, image_yscale,
            image_angle, image_blend, image_alpha
        );
    }
}

function scr_draw_tenna_battle_ext()
{
    if !instance_exists(obj_tenna) exit;
    
    obj_tenna.animsiner++;
    obj_tenna.animsinerb++;
    obj_tenna.armshake *= -1;
    obj_tenna.armshakesiner++;
    
    var _color = 16777215;
    var animsiner = obj_tenna.animsiner;
    var animsinerb = obj_tenna.animsinerb;
    var armshake = obj_tenna.armshake;
    var armshakesiner = obj_tenna.armshakesiner;
    var chargingup = 1;
    
    var bx = sin(animsiner / 10) * 5;
	var by = -abs(cos(animsiner / 10)) * 5;
	var armx = sin(animsiner / 10) * 9;
	var army = cos(animsiner / 10) * 6;
	var headx = sin(animsiner / 10) * 8;
	var heady = (sin(animsiner / 10) * 6) + 4;
	var legx = sin((animsiner + 4) / 10) * 5;
	var legy = cos(animsiner / 10) * 2;
	var image = animsiner / 10;
	var armshakevalue = clamp((sin((armshakesiner / 30) - 1) * 1.5) - 1, 0, 4);
    var armshakey = armshakevalue * armshake;
    var headimage = 2;
	var loopimage = 1.5 + (sin(image) * 1.5);
	var loopimage1 = 1 + (sin(image) * 1);
	var tailimage = image;
    
    if (chargingup == 0)
    {
        armshakey = 0;
        armshakevalue = 0;
    }
    
    var _x = obj_tenna.x;
    var _y = obj_tenna.y;
    var _image_xscale = obj_tenna.image_xscale;
    var _image_yscale = obj_tenna.image_yscale;
    var _image_angle = obj_tenna.image_angle;
    var _image_alpha = obj_tenna.image_alpha;
    
    draw_sprite_ext(spr_tenna_battle_leg_l, image, _x - legx, _y + legy, _image_xscale, 
		_image_yscale, _image_angle, _color, _image_alpha);
    draw_sprite_ext(spr_tenna_battle_leg_r, image, _x + legx, _y - (legy / 4), _image_xscale, 
		_image_yscale, _image_angle, _color, _image_alpha);
    draw_sprite_ext(spr_tenna_battle_tails, tailimage, (_x + (bx / 2)) - 4, _y + by, _image_xscale, 
		_image_yscale, _image_angle, _color, _image_alpha);
    draw_sprite_ext(spr_tenna_battle_arm_back, 3 - loopimage, ((_x + bx) - (armx * 1.5)) + 12, (_y + by) - army, _image_xscale, 
		_image_yscale, _image_angle, _color, _image_alpha);
    draw_sprite_ext(spr_tenna_battle_torso, 0, _x + bx, _y + by, _image_xscale, 
		_image_yscale, _image_angle, _color, _image_alpha);
    draw_sprite_ext(spr_tenna_battle_tie, 0, _x + bx, _y + by, _image_xscale, 
		_image_yscale, _image_angle, _color, _image_alpha);
    draw_sprite_ext(spr_tenna_battle_face, clamp(round(obj_tenna.face_frame), 0, 2), ((_x + bx) - headx) + 2 + (armshakey / 2), (_y + by + heady) - 2 - (armshakey / 2), _image_xscale, 
		_image_yscale, _image_angle, _color, _image_alpha);
    draw_sprite_ext(spr_tenna_battle_arm_front, loopimage, ((_x + bx) - armx) + armshakey, _y + by + army + armshakey, _image_xscale, 
		_image_yscale, _image_angle, _color, _image_alpha);
}

function scr_reveal_mike_trio()
{
    if instance_exists(obj_tennabg)
    {
        obj_tennabg.trio_reveal = true;
    }
}