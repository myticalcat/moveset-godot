extends Sprite2D


class_name Character

signal move_chosen(move: Moves.Types)

enum Stat{
	AGI,
	STR,
	INT,
}

enum Direction{
	LEFT,
	RIGHT,
}

@export var is_interactive: bool = false:
	set(v):
		if v == false:
			collision.queue_free()
			mouse_area.queue_free()
			special_atk_btn.queue_free()
			light_atk_btn.queue_free()
			strong_atk_btn.queue_free()
			parry_btn.queue_free()
			move_forward_btn.queue_free()
			move_backward_btn.queue_free()
		else:
			for btn in _buttons():
				btn.visible = false
				btn.mouse_entered.connect(_cancel_hide)
				btn.mouse_exited.connect(_schedule_hide)
			collision.shape.radius = self.texture.get_width() * 3.0 / 4
			mouse_area.mouse_entered.connect(_fan_out)
			mouse_area.mouse_exited.connect(_schedule_hide)
			special_atk_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.SPECIAL_ATK))
			light_atk_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.LIGHT_ATK))
			strong_atk_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.STRONG_ATK))
			parry_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.PARRY))
			move_forward_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.FORW_MV))
			move_backward_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.BACK_MV))

		is_interactive = v
		
@export var collision: CollisionShape2D
@export var mouse_area: Area2D
@export var special_atk_btn: Button
@export var light_atk_btn: Button
@export var strong_atk_btn: Button
@export var parry_btn: Button
@export var move_forward_btn: Button
@export var move_backward_btn: Button

var turn_off := false
var _tween: Tween
var _hiding := false
var _fanned_out := false
var _fan_hiding := false
var _enable := false

const RADIUS = 200.0

var char_name: String

@export var prefered_position: int = 0

var is_staggered := false
var is_dead := false

@export var sprite_dict: Dictionary = {
	Moves.Types.LIGHT_ATK: [],
	Moves.Types.STRONG_ATK: [],
	Moves.Types.SPECIAL_ATK: [],
	Moves.Types.PARRY: [],
	Moves.Types.FORW_MV: [],
	Moves.Types.BACK_MV: [],
	Moves.Types.STAGGER: [],
}

var max_health_point: float
var health_point: float
var move_history: Array[Moves.Types] = []
var chipset: Chipset
var conditions: Array[Condition] = []

@export var agi_stat: float = 0.0
@export var str_stat: float = 0.0
@export var int_stat: float = 0.0

@export var light_atk_range: int = 0
@export var strong_atk_range: int = 0
@export var move_range: int = 1

var side: Direction:
	set(dir):
		_side = dir
		flip_h = dir == Direction.LEFT
	get: return _side
var _side := Direction.RIGHT


func _ready() -> void:
	if not is_interactive:
		return
	for btn in _buttons():
		btn.visible = false
		btn.mouse_entered.connect(_cancel_hide)
		btn.mouse_exited.connect(_schedule_hide)
	collision.shape.radius = self.texture.get_width() * 3.0 / 4
	mouse_area.mouse_entered.connect(_fan_out)
	mouse_area.mouse_exited.connect(_schedule_hide)
	special_atk_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.SPECIAL_ATK))
	light_atk_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.LIGHT_ATK))
	strong_atk_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.STRONG_ATK))
	parry_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.PARRY))
	move_forward_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.FORW_MV))
	move_backward_btn.pressed.connect(func(): move_chosen.emit(Moves.Types.BACK_MV))


func execute_special_attack(_o: Character, _bm: BattleManager):
	pass

func get_pattern_speed() -> float:
	return chipset.get_special_speed(self)

func get_movement_forward() -> int:
	if side == Direction.LEFT:
		return 1
	else:
		return -1

func add_to_history(mv: Moves.Types):
	move_history.append(mv)

func get_movement_backward() -> int:
	return -1 * get_movement_forward()

func get_base_damage() -> float:
	return chipset.get_damage(self)

func take_damage(damage: float):
	health_point = max(health_point - damage, 0)
	if health_point == 0:
		is_dead = true

func query_move(_opponent_history: Array[Moves.Types], _distance_to_opp: int) -> Moves.Types:
	if is_interactive:
		turn_on_button()
		return await query_for_input()
	return Moves.Types.FORW_MV

func query_for_input() -> Moves.Types:
	_enable = true
	var move: Moves.Types = await move_chosen
	turn_off_button()
	_enable = false
	return move

func is_suffix_pattern() -> bool:
	var pattern_length := len(chipset.pattern)
	if move_history.slice(-pattern_length) == chipset.pattern:
		return true
	return false

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
	collision.shape.radius = self.texture.get_width() * 3.0 / 4
	for i in buttons.size():
		_tween.tween_property(buttons[i], "position", center, 0.15).set_delay(i * 0.02)
		_tween.tween_property(buttons[i], "scale", Vector2.ZERO, 0.15).set_delay(i * 0.02)
	_tween.finished.connect(func():
		for btn in buttons:
			btn.visible = false
		_fan_hiding = false
	)
