depth = -9999;
speaker	  = noone;
quote		= "(unset)";
wrap_w	   = 20;
mouth_off_x  = -20;
mouth_off_y  = -80;
chars_per_s  = 0;
flip_talkbox = false;
ready_to_advance = false;
rounded_corners = true;
txt_font	   = fnt_talkbox;
line_sep	   = 18;
pad_x		  = 5;
pad_x_mini	 = 4;
pad_y		  = 5;
pad_y_mini	 = 4;
rect_color	 = c_white;
text_color	 = c_black;
triangle_sprite= spr_talkbox_triangle;
triangle_xoff  = -20;
triangle_yoff  = -40;

screen_margin  = 12;

char_index   = 0;
char_timer   = 0;
hold_seconds = 0;

speak_snd = noone;
snd_delay = 2;
snd_count = 0;
speak_vol = 1;

_text_h_full = 0;
_half_h	  = 0;

_layout_text  = "";
_text_w_full  = 0;
_layout_text_pause = "";


pause_comma	= 0.20;
pause_period   = 0.40;
pause_excl	 = 0.40;
pause_question = 0.40;
pause_semi	 = 0.20;
pause_colon	= 0.20;
pause_ellipsis = 0.20;

pause_events = [];
pause_ptr	= 0;

end_hold_seconds = 0;

keep_speaker_animating = false;

dim_alpha = 0;

instant_cutoff = false; // if true, this box advances the instant its text finishes typing — no hold, no waiting for Z

function _wrap_text_to_width(_s, _max_w) {
	draw_set_font(txt_font);

	var out  = "";
	var line = "";
	var last_space = 0;

	var len = string_length(_s);

	for (var i = 1; i <= len; i++) {
		var ch = string_char_at(_s, i);

		if (ch == "\n" || ch == "\r") {
			out += line + ch;
			line = "";
			last_space = 0;
			continue;
		}

		line += ch;
		if (ch == " ") {
			last_space = string_length(line);
		}

		if (string_width(line) > _max_w) {
			var break_pos;

		if (last_space > 0) {
			var keep = string_copy(line, 1, last_space - 1);
			out += keep + "\n";

			line = string_copy(line, last_space + 1, string_length(line) - last_space);
		} else {
			var bp = max(1, string_length(line) - 1);
			out += string_copy(line, 1, bp) + "\n";
			line = string_copy(line, bp + 1, string_length(line) - bp);
		}

		while (string_length(line) > 0 && string_char_at(line, 1) == " ") {
			line = string_delete(line, 1, 1);
		}

		last_space = 0;
		var lr = string_length(line);
		for (var j = 1; j <= lr; j++) {
			if (string_char_at(line, j) == " ") last_space = j;
		}


			last_space = 0;
			var lr2 = string_length(line);
			for (var j = 1; j <= lr2; j++) {
				if (string_char_at(line, j) == " ") last_space = j;
			}
		}
	}

	out += line;
	return out;
}

function _build_pause_events_from_layout() {
	pause_events = [];
	pause_ptr = 0;

	var s = _layout_text_pause;
	var n = string_length(s);

	for (var i = 1; i <= n; i++) {
		var ch = string_char_at(s, i);
		var next_char = (i < n) ? string_char_at(s, i + 1) : "";
		var is_boundary = (next_char == " " || next_char == "" || next_char == "|");

		if (ch == ",")
			pause_events[array_length(pause_events)] = { idx: i, sec: pause_comma };

		else if (ch == ";" && next_char == " ")
			pause_events[array_length(pause_events)] = { idx: i, sec: pause_semi };

		else if (ch == ":" && next_char == " ")
			pause_events[array_length(pause_events)] = { idx: i, sec: pause_colon };

		else if (ch == "." && is_boundary) {
			var prev_char = (i > 1) ? string_char_at(s, i - 1) : "";
			var _sec = (prev_char == ".") ? pause_ellipsis : pause_period;
			pause_events[array_length(pause_events)] = { idx: i, sec: _sec };
		}
		else if (ch == "!" && is_boundary)
			pause_events[array_length(pause_events)] = { idx: i, sec: pause_excl };

		else if (ch == "?" && is_boundary)
			pause_events[array_length(pause_events)] = { idx: i, sec: pause_question };

		else if (ch == "\r")
			pause_events[array_length(pause_events)] = { idx: i, sec: pause_period };
	}
}


function _recalc_layout() {
	draw_set_font(txt_font);

	var q = string_replace_all(quote, "\n", "\r");
	_layout_text_pause = _wrap_text_to_width(q, wrap_w);
	_layout_text = string_replace_all(_layout_text_pause, "\r", "\n");


	_text_w_full = 0;

	var lines = string_split(_layout_text, "\n");
	var line_count = array_length(lines);
	for (var i = 0; i < line_count; i++) {
		var w = string_width(lines[i]);
		if (w > _text_w_full) _text_w_full = w;
	}

	_text_h_full = max(line_sep, line_count * line_sep);
	_half_h = _text_h_full * 0.5;
	_build_pause_events_from_layout();
}

_recalc_layout();

