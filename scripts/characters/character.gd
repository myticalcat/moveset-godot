extends Sprite2D


class_name Character

enum Stat{
	AGI,
	STR,
	INT,
}

enum Direction{
	LEFT,
	RIGHT,
}

var _delegate: Character = null

func set_delegate(d: Character) -> void:
	_delegate = d

@export var prefered_position: int:
	get: return _delegate.prefered_position if _delegate else _prefered_position
	set(v):
		if _delegate: _delegate.prefered_position = v
		else: _prefered_position = v
var _prefered_position := 0

var is_staggered := false:
	set(new):
		if _delegate:
			_delegate.is_staggered = new
		else:
			_is_staggered = new
			texture = sprite_dict[Moves.Types.STAGGER][0]
	get: return _delegate.is_staggered if _delegate else _is_staggered
var _is_staggered := false

var sprite_dict: Dictionary:
	get: return _delegate.sprite_dict if _delegate else _sprite_dict
	set(v):
		if _delegate: _delegate.sprite_dict = v
		else: _sprite_dict = v
var _sprite_dict: Dictionary = {
	Moves.Types.LIGHT_ATK: [],
	Moves.Types.STRONG_ATK: [],
	Moves.Types.SPECIAL_ATK: [],
	Moves.Types.PARRY: [],
	Moves.Types.FORW_MV: [],
	Moves.Types.BACK_MV: [],
	Moves.Types.STAGGER: [],
}

var move_history: Array[Moves.Types]:
	get: return _delegate.move_history if _delegate else _move_history
	set(v):
		if _delegate: _delegate.move_history = v
		else: _move_history = v
var _move_history: Array[Moves.Types] = []

var chipset: Chipset:
	get: return _delegate.chipset if _delegate else _chipset
	set(v):
		if _delegate: _delegate.chipset = v
		else: _chipset = v
var _chipset: Chipset

var conditions: Array[Condition]:
	get: return _delegate.conditions if _delegate else _conditions
	set(v):
		if _delegate: _delegate.conditions = v
		else: _conditions = v
var _conditions: Array[Condition] = []

@export var agi_stat: float:
	get: return _delegate.agi_stat if _delegate else _agi_stat
	set(v):
		if _delegate: _delegate.agi_stat = v
		else: _agi_stat = v
var _agi_stat := 0.0

@export var str_stat: float:
	get: return _delegate.str_stat if _delegate else _str_stat
	set(v):
		if _delegate: _delegate.str_stat = v
		else: _str_stat = v
var _str_stat := 0.0

@export var int_stat: float:
	get: return _delegate.int_stat if _delegate else _int_stat
	set(v):
		if _delegate: _delegate.int_stat = v
		else: _int_stat = v
var _int_stat := 0.0

@export var light_atk_range: int:
	get: return _delegate.light_atk_range if _delegate else _light_atk_range
	set(v):
		if _delegate: _delegate.light_atk_range = v
		else: _light_atk_range = v
var _light_atk_range := 0

@export var strong_atk_range: int:
	get: return _delegate.strong_atk_range if _delegate else _strong_atk_range
	set(v):
		if _delegate: _delegate.strong_atk_range = v
		else: _strong_atk_range = v
var _strong_atk_range := 0

@export var move_range: int:
	get: return _delegate.move_range if _delegate else _move_range
	set(v):
		if _delegate: _delegate.move_range = v
		else: _move_range = v
var _move_range := 1

var side: Direction:
	set(dir):
		if _delegate:
			_delegate.side = dir
		else:
			_side = dir
			flip_h = dir == Direction.LEFT
	get: return _delegate.side if _delegate else _side
var _side := Direction.RIGHT

func execute_special_attack(o : Character, bm : BattleManager):
	pass

func get_pattern_speed() -> float:
	return chipset.get_special_speed(self)

func get_movement_forward() -> int:
	if side == Direction.LEFT:
		return 1
	else:
		return -1

func add_to_history(mv : Moves.Types):
	move_history.append(mv)

func get_movement_backward() -> int:
	return -1 * get_movement_forward()

func get_base_damage() -> float:
	return chipset.get_damage(self)

func take_damage(damage : float):
	pass

func query_move(opponent_history : Array[Moves.Types], distance_to_opp : int) -> Moves.Types:
	return Moves.Types.FORW_MV

func is_suffix_pattern() -> bool:
	var pattern_length := len(chipset.pattern)
	if move_history.slice(-pattern_length) == chipset.pattern:
		return true
	return false
