extends Sprite2D

class_name Condition

enum OP_TYPE{
	ADD,
	MULT,
	EXP,
}

enum ACTV_TYPE{
	DAMAGE,
	LIGHT_ATK,
	STRONG_ATK,
	SPECIAL_ATK,
	MOVE,
	BACK_MV,
	FORW_MV,
	RANGE,
}

var _name : String
var sprite : Texture2D
var activation_types : Array[ACTV_TYPE]
var operation : OP_TYPE
var turn := 1
var priority := -1
var value : float = -1


func shake(magnitude : float) -> void:
	pass