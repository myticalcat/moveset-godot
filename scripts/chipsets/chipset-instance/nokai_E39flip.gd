extends Chipset

class_name NokaiFlip


func _init() -> void:
    pattern = [
        Moves.Types.STRONG_ATK,
        Moves.Types.STRONG_ATK,
        Moves.Types.LIGHT_ATK,
        Moves.Types.SPECIAL_ATK,
    ]
    sprite = null
    name = "Nokai E39flip"

func get_damage(c: Character) -> float:
    return c.str_stat

func get_special_speed(c: Character) -> float:
    return c.agi_stat