extends Character

class_name Player

signal move_chosen(move: Moves.Types)

const RADIUS = 200.0

@export var collision : CollisionShape2D
@export var mouse_area: Area2D
@export var special_atk_btn: Button
@export var light_atk_btn: Button
@export var strong_atk_btn: Button
@export var parry_btn: Button
@export var move_forward_btn: Button
@export var move_backward_btn: Button

var turn_off := false
var character : Character
var _tween: Tween
var _hiding := false
var _fanned_out := false
var _fan_hiding := false
var _enable := true

func _ready() -> void:
	for btn in _buttons():
		btn.visible = false
		btn.mouse_entered.connect(_cancel_hide)
		btn.mouse_exited.connect(_schedule_hide)
	collision.shape.radius = self.texture.get_width() * 3.0/4
	mouse_area.mouse_entered.connect(_fan_out)
	mouse_area.mouse_exited.connect(_schedule_hide)
	_enable = false
	special_atk_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.SPECIAL_ATK))
	light_atk_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.LIGHT_ATK))
	strong_atk_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.STRONG_ATK))
	parry_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.PARRY))
	move_forward_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.FORW_MV))
	move_backward_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.BACK_MV))

func query_for_input() -> Moves.Types:
	_enable = true
	var move: Moves.Types = await move_chosen
	turn_off_button()
	_enable = false
	return move

func turn_off_button():
	turn_off = true
	_fan_hide()

func turn_on_button():
	turn_off = false

func _buttons() -> Array[Button]:
	return [special_atk_btn, light_atk_btn, strong_atk_btn,
			parry_btn, move_forward_btn, move_backward_btn]

func _cancel_hide() -> void:
	_hiding = false
	_fan_hiding = false

func _schedule_hide() -> void:
	_hiding = true
	await get_tree().create_timer(0.4).timeout
	if _hiding and not _fan_hiding:
		_fan_hide()

func _fan_out() -> void:
	if turn_off:
		return

	_hiding = false
	if _fanned_out:
		return
	_fanned_out = true
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	var buttons := _buttons()
	collision.shape.radius = RADIUS + buttons[0].size.length() / 2.0
	for i in buttons.size():
		var angle := i * (TAU / buttons.size())
		var target := (Vector2(cos(angle), sin(angle)) * RADIUS) - buttons[i].size / 2.0
		buttons[i].visible = true
		buttons[i].scale = Vector2.ZERO
		buttons[i].pivot_offset = buttons[i].size / 2.0
		buttons[i].position = Vector2.ZERO - buttons[i].size / 2.0
		_tween.tween_property(buttons[i], "position", target, 0.2).set_delay(i * 0.07)
		_tween.tween_property(buttons[i], "scale", Vector2.ONE, 0.2).set_delay(i * 0.07)

func _fan_hide() -> void:
	_fan_hiding = true
	_fanned_out = false
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	var buttons := _buttons()
	var center := Vector2.ZERO - buttons[0].size / 2.0
	collision.shape.radius = self.texture.get_width() * 3.0/4
	for i in buttons.size():
		_tween.tween_property(buttons[i], "position", center, 0.15).set_delay(i * 0.02)
		_tween.tween_property(buttons[i], "scale", Vector2.ZERO, 0.15).set_delay(i * 0.02)
	_tween.finished.connect(func():
		for btn in buttons:
			btn.visible = false
		_fan_hiding = false
	)
