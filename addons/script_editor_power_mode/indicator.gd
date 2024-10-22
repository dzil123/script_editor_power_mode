extends TextureRect

var strength = 0.0
var timeout = 0.0
var residual = 0.0


static func exp_decay(a: float, b: float, decay: float, dt: float):
	return b + (a - b) * exp(-decay * dt)


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	texture = preload("white_tex.tres")
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 20)
	pivot_offset = size * Vector2(1.0, 0.5)
	scale = Vector2(0, 50)


func _process(delta: float) -> void:
	var x = 1 - exp(strength / -10)
	x = maxf(x * 0.7 * (get_parent() as Control).size.x - 5, 0)
	scale.x = exp_decay(scale.x, x, 20.0, delta)
	residual = maxf(x - scale.x, 0)
	var decay = 1 - pow(timeout, 0.5)
	strength = clampf(exp_decay(strength, strength * 0.6 - 0.1, decay, delta), 0, strength)
	timeout = maxf(timeout - delta, 0)


func pump():
	strength += 1
	timeout = 1.3


func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			strength = 0
