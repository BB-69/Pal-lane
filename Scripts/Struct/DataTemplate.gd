extends Node
class_name DataTemplate

var data: Dictionary = {
	"total_pal": 0,
	"time_lapsed": 0.0,
}

func _init(
	total_pal: int,
	time_lapsed: float,
):
	data["total_pal"] = total_pal
	data["time_lapsed"] = time_lapsed
	
