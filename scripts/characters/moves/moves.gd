class_name Moves

enum Types{
	LIGHT_ATK,
	STRONG_ATK,
	SPECIAL_ATK,
	BACK_MV,
	FORW_MV,
	PARRY,
	STAGGER,
}

static var texture_type = {
	Types.LIGHT_ATK : preload("res://assets/32_lt_ak.jpg"),
	Types.STRONG_ATK : preload("res://assets/32_st_ak.jpg"),
	Types.SPECIAL_ATK : preload("res://assets/32_sp_ak.jpg"),
	Types.BACK_MV : preload("res://assets/32_bw_mv.jpg"),
	Types.FORW_MV : preload("res://assets/32_fw_mv.jpg"),
	Types.PARRY : preload("res://assets/32_pr.jpg"),
}

static func type_to_texture(mv : Types) -> Texture2D:
	return texture_type[mv]
	
static func type_to_string(mv : Moves.Types):
	return{
		Types.LIGHT_ATK : "lt_atk",
		Types.STRONG_ATK : "st_atk",
		Types.SPECIAL_ATK : "sp_atk",
		Types.BACK_MV : "bw_mv",
		Types.FORW_MV : "fw_mv",
		Types.PARRY : "pr",
		Types.STAGGER : "sg",
	}[mv]

static func string_to_type(str : String):
	var mv := Types.STAGGER
	var str_to_mv := {
		"lt_atk" : Types.LIGHT_ATK,
		"st_atk" : Types.STRONG_ATK,
		"sp_atk" : Types.SPECIAL_ATK,
		"bw_mv" : Types.BACK_MV,
		"fw_mv" : Types.FORW_MV,
		"pr" : Types.PARRY,
		"sg" : Types.STAGGER,
	}
	if str_to_mv.get(str) != null:
		return mv
	else:
		return str_to_mv[str]