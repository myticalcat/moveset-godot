extends CanvasLayer

@export var l_name : Label
@export var l_level: Label
@export var l_hp_lab : Label
@export var l_hp_prg : ProgressBar
@export var l_mv_hst : HBoxContainer

@export var r_name : Label
@export var r_level: Label
@export var r_hp_lab : Label
@export var r_hp_prg : ProgressBar
@export var r_mv_hst : HBoxContainer


var l_char : Character
var r_char : Character

var l_prev_mv : Array[Moves.Types]
var r_prev_mv : Array[Moves.Types]

func setup(cl : Character, cr : Character):
	l_char = cl
	r_char = cr
	l_name.text = cl.char_name
	r_name.text = cr.char_name
	l_hp_prg.max_value = l_char.max_health_point
	r_hp_prg.max_value = r_char.max_health_point
	l_prev_mv = []
	l_prev_mv.append_array(l_char.move_history)
	r_prev_mv = []
	r_prev_mv.append_array(r_char.move_history)
	update_ui()

func update_ui():
	l_hp_lab.text = str(l_char.max_health_point) + " / " + str(l_char.health_point)
	r_hp_lab.text = str(l_char.health_point) + " / " + str(r_char.max_health_point)
	l_hp_prg.value = l_char.health_point
	r_hp_prg.value = r_char.health_point
	
func _process(delta: float) -> void:
	update_ui()
