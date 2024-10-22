@tool
extends EditorPlugin

const Util = preload("util.gd")
const PowerIndicator = preload("indicator.gd")

var pumpable = true
var indicator: PowerIndicator
var emitter: CPUParticles2D
var code_edit: CodeEdit
var combo: Label
var emit_time = 0.01
var timer: Timer
var last_editor = null


func _enter_tree():
	var script_editor = EditorInterface.get_script_editor()
	script_editor.script_close.connect(refresh)
	script_editor.editor_script_changed.connect(refresh)

	indicator = PowerIndicator.new()
	emitter = preload("particle_emitter.tscn").instantiate()
	combo = preload("combo.tscn").instantiate()
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_timeout)
	add_child(timer)

	load_code_edits()


func _exit_tree():
	var script_editor = EditorInterface.get_script_editor()
	script_editor.script_close.disconnect(refresh)
	script_editor.editor_script_changed.disconnect(refresh)

	clear_code_edits()

	indicator.queue_free()
	indicator = null
	emitter.queue_free()
	emitter = null
	combo.queue_free()
	combo = null
	timer.timeout.disconnect(_timeout)
	timer.queue_free()


func refresh(_script):
	last_editor = EditorInterface.get_script_editor().get_current_editor()
	clear_code_edits()
	load_code_edits.call_deferred()


func load_code_edits():
	if code_edit != null:
		return

	if last_editor == null:
		return

	code_edit = Util.get_child_of_type(last_editor, "CodeEdit", true)

	code_edit.lines_edited_from.connect(_on_signal)
	code_edit.add_child(emitter)
	code_edit.add_child(indicator)
	code_edit.add_child(combo)


func clear_code_edits():
	if code_edit == null:
		return

	code_edit.lines_edited_from.disconnect(_on_signal)
	code_edit.remove_child(emitter)
	code_edit.remove_child(indicator)
	code_edit.remove_child(combo)

	code_edit = null


func _on_signal(_from_line: int, _to_line: int):
	if code_edit == null:
		return

	if pumpable:
		indicator.pump()
		pumpable = false

	emitter.position = code_edit.get_caret_draw_pos()
	emitter.emitting = true

	set_deferred("pumpable", true)

	#await get_tree().create_timer(emit_time).timeout
	#emitter.emitting = false
	timer.start(emit_time)


func _process(_delta):
	if last_editor != EditorInterface.get_script_editor().get_current_editor():
		refresh(null)

	combo.modulate.a = minf(1.0, indicator.strength * 2.0 - 0.1)
	combo.offset_right = -((indicator.scale.x + indicator.residual * 2 + 10) * 1.2)

	if indicator.strength > 0.0:
		combo.text = "%sx" % ceili(indicator.strength)

	var x = 1 - exp(indicator.strength / -30)
	emitter.scale_amount_max = max(emitter.scale_amount_min, x * 20)


func _timeout():
	emitter.emitting = false
