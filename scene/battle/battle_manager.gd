extends Node2D

class_name BattleManager 

@export var camera : Camera2D 
var debug = true

var arena_size = 9


@export var player : Player
@export var enemy : Character
var character_pos : Dictionary = {}
var _move_tweens : Dictionary = {}

var arena_mid_point : Array[int] = [
	-1000,
	-800,
	-600,
	-400,
	-200,
	0,
	200,
	400,
	600,
	800,
]


func _ready() -> void:
	if debug == true:
		player.chipset = NokaiFlip.new()
		enemy.chipset = NokaiFlip.new()
		start_game(player, enemy)
		
func start_game(player_new : Player, enemy_new: Character):
	self.player = player_new
	self.enemy = enemy_new
	
	self.player.side = Character.Direction.LEFT
	self.enemy.side = Character.Direction.RIGHT
	
	character_pos[player_new] = self.player.prefered_position
	character_pos[enemy_new] = arena_size - self.enemy.prefered_position

	player.global_position = Vector2(arena_mid_point[character_pos[player]], 0)
	enemy.global_position = Vector2(arena_mid_point[character_pos[enemy]], 0)

	if self.player:
		start_round()
	else:
		start_round() # kalo nanti multiplayer

func start_round():
	SignalBus.battle_start.emit()
	while true:
		var enemy_mv : Moves.Types = Moves.Types.STAGGER
		var player_mv : Moves.Types = Moves.Types.STAGGER
		if not enemy.is_staggered:
			enemy_mv = enemy.query_move(player.move_history, get_distance_char())

		if not player.is_staggered:
			player_mv = await player.query_for_input()

		player.is_staggered = false
		enemy.is_staggered = false

		var player_spd = speed(player, player_mv)
		var enemy_spd = speed(enemy, enemy_mv)

		if player_spd == enemy_spd:
			if randf() < 0.6:
				resolve_moves(player, enemy, player_mv, enemy_mv, true)
				await get_tree().create_timer(0.1).timeout
				resolve_moves(enemy, player, enemy_mv, player_mv, false)
			else:
				resolve_moves(enemy, player, enemy_mv, player_mv, true)
				await get_tree().create_timer(0.1).timeout
				resolve_moves(player, enemy, player_mv, enemy_mv, false)
		elif player_spd > enemy_spd:
			resolve_moves(player, enemy, player_mv, enemy_mv, true)
			await get_tree().create_timer(0.1).timeout
			resolve_moves(enemy, player, enemy_mv, player_mv, false)
		else:
			resolve_moves(enemy, player, enemy_mv, player_mv, true)
			await get_tree().create_timer(0.1).timeout
			resolve_moves(player, enemy, player_mv, enemy_mv, false)


func resolve_moves(actor : Character, subject : Character, mv : Moves.Types, subject_mv : Moves.Types, moved_first : bool):

	actor.add_to_history(mv)

	if mv == Moves.Types.LIGHT_ATK:
		print("light attack")
		resolve_light_attack(actor, subject)
	if mv == Moves.Types.STRONG_ATK:
		print("strong attack")
		resolve_strong_attack(actor, subject)
	if mv == Moves.Types.SPECIAL_ATK:
		print("special attack")
		actor.execute_special_attack(subject, self)
	if mv == Moves.Types.FORW_MV or mv == Moves.Types.BACK_MV:
		print("move")
		resolve_step(actor, mv)
	if mv == Moves.Types.PARRY:
		print("parry")
		resolve_parry(actor, subject, subject_mv, moved_first)
	if mv == Moves.Types.STAGGER:
		pass

func resolve_parry(_actor : Character, subject : Character, subject_mv : Moves.Types, moved_first : bool):
	if moved_first and subject_mv == Moves.Types.LIGHT_ATK:
		subject.is_staggered = true

func resolve_light_attack(actor : Character, subject : Character):
	var attack_range = actor.light_atk_range
	var conditions : Array[Condition] = []
	conditions.append_array(actor.conditions)
	conditions.append_array(ConditionManager.field_condition)
	attack_range = resolves_number(attack_range, [Condition.ACTV_TYPE.RANGE], conditions)
	attack_range = max(attack_range, 0)
	var damage = 0
	if attack_range >= get_distance_char():
		damage = actor.get_base_damage()
		conditions.append_array(subject.conditions)
		resolves_number(damage,[
			Condition.ACTV_TYPE.DAMAGE,
			Condition.ACTV_TYPE.LIGHT_ATK
		], conditions)

		subject.take_damage(damage)

func resolve_strong_attack(actor : Character, subject : Character):
	var attack_range = actor.strong_atk_range
	var conditions : Array[Condition] = []
	conditions.append_array(actor.conditions)
	conditions.append_array(ConditionManager.field_condition)
	attack_range = resolves_number(attack_range, [Condition.ACTV_TYPE.RANGE], conditions)
	attack_range = max(attack_range, 0)
	var damage = 0
	if attack_range >= get_distance_char():
		damage = actor.get_base_damage() * 2 # strong attack dikali 2
		conditions.append_array(subject.conditions)
		resolves_number(damage,[
			Condition.ACTV_TYPE.DAMAGE,
			Condition.ACTV_TYPE.STRONG_ATK
		], conditions)

		subject.take_damage(damage)

func resolves_number(base : float, active_type : Array[Condition.ACTV_TYPE], conditions : Array[Condition]) -> float:
	conditions.sort_custom(func (a : Condition ,b : Condition) : return a.priority > b.priority)
	var old = base
	for c in conditions:
		var active = false
		
		for act in c.activation_types:
			if act in active_type:
				active = true
				break
		
		if not active:
			continue

		if c.operation == Condition.OP_TYPE.ADD:
			base += c.value
			continue
		if c.operation == Condition.OP_TYPE.MULT:
			base *= c.value
			continue
		if c.operation == Condition.OP_TYPE.EXP:
			base **= c.value

		c.shake(base / old)

	return base

func resolve_step(actor : Character, mv : Moves.Types):
	var movement : int

	if mv == Moves.Types.BACK_MV:
		movement = actor.get_movement_backward()
	if mv == Moves.Types.FORW_MV:
		movement = actor.get_movement_forward()

	var move_to = character_pos[actor] + movement
	move_to = min(max(move_to, 0), arena_size)

	character_pos[actor] = move_to

	if character_pos[player] > character_pos[enemy]:
		player.side = Character.Direction.RIGHT
		enemy.side = Character.Direction.LEFT 
	elif  character_pos[player] < character_pos[enemy]:
		player.side = Character.Direction.LEFT
		enemy.side = Character.Direction.RIGHT

	if _move_tweens.get(actor):
		_move_tweens[actor].kill()
	var tween := create_tween()
	_move_tweens[actor] = tween
	tween.tween_property(actor, "global_position", Vector2(arena_mid_point[move_to], 0), 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func speed(c : Character, move : Moves.Types) -> float:
	if move == Moves.Types.STAGGER:
		return -1.0
	if move == Moves.Types.SPECIAL_ATK:
		if c.is_suffix_pattern():
			return c.get_pattern_speed()
		return -1.0
	return move_base_speed(move, c.agi_stat)


func move_base_speed(move : Moves.Types, agi : float) -> float:
	return {
		Moves.Types.BACK_MV : agi,
		Moves.Types.FORW_MV : agi,
		Moves.Types.PARRY : agi + 100,
		Moves.Types.LIGHT_ATK : agi,
		Moves.Types.STRONG_ATK : agi * 0.5,
		Moves.Types.SPECIAL_ATK : agi,
	}[move]
 

func get_distance_char() -> int:
	return abs(character_pos[player] - character_pos[enemy])
