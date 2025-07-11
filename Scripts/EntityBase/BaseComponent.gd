extends Node
class_name BaseComponent

var id: int
@export var tag: String = "None"
@export var is_player: bool = false

func _init(new_tag: String = tag):
	id = Stat.id_count
	Stat.id_count += 1
	
	tag = new_tag
