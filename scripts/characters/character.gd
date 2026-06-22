extends Sprite2D


class_name Character

@export var prefered_position := 0
var is_staggered = false
var move_history : Array[Moves.Types] = []
var chipset : Chipset
var conditions : Array[Condition] = []
@export var agi_stat := 0.0
@export var str_stat := 0.0
@export var int_stat := 0.0
@export var light_atk_range := 0
@export var strong_atk_range := 0
@export var move_range := 1


enum Stat{
	AGI,
	STR,
	INT,
}

enum Direction{
	LEFT,
	RIGHT,
}

var side : Direction:
	set(dir):
		side = dir
		if dir == Direction.LEFT:
			self.flip_h = true
		else:
			self.flip_h = false

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
