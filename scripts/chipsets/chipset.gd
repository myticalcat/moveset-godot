class_name Chipset

var pattern : Array[Moves.Types]
var sprite : Texture2D
var name  : String

func get_damage(c : Character) -> float:
    return -1

func get_special_speed(c: Character) -> float:
    return 0