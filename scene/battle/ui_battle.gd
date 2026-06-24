extends CanvasLayer

class_name UIBattle

@export var l_name : Label
@export var l_hp_lab : Label
@export var l_hp_prg : ProgressBar
@export var l_mv_hst : HBoxContainer
@export var l_mv_srl : ScrollContainer
@export var l_portrait : TextureRect

@export var r_name : Label
@export var r_hp_lab : Label
@export var r_hp_prg : ProgressBar
@export var r_mv_hst : HBoxContainer
@export var r_portrait : TextureRect

@export var next_pred_cl : Array[Label]
@export var next_pred_tx : Array[TextureRect]

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
	for c in l_mv_hst.get_children():
		c.queue_free()
	for c in r_mv_hst.get_children():
		c.queue_free()

	update_ui()

func update_prediction(mv : Moves.Types, confidence : float):
	next_pred_cl[0].text = "Confidence: .2%f" % confidence


func update_ui():
	if not l_char or not r_char:
		return

	l_hp_lab.text = str(l_char.max_health_point) + " / " + str(l_char.health_point)
	r_hp_lab.text = str(l_char.health_point) + " / " + str(r_char.max_health_point)
	l_hp_prg.value = l_char.health_point
	r_hp_prg.value = r_char.health_point
	if l_prev_mv != l_char.move_history:
		l_prev_mv = l_char.move_history.duplicate()
		for c in l_mv_hst.get_children():
			c.queue_free()
		for mv in l_prev_mv:
			var tx := TextureRect.new()
			tx.texture = Moves.type_to_texture(mv)
			l_mv_hst.add_child(tx)
	if r_prev_mv != r_char.move_history:
		r_prev_mv = r_char.move_history.duplicate()
		for c in r_mv_hst.get_children():
			c.queue_free()
		for mv in r_prev_mv:
			var tx := TextureRect.new()
			tx.texture = Moves.type_to_texture(mv)
			r_mv_hst.add_child(tx)

func _process(_delta: float) -> void:
	update_ui()
