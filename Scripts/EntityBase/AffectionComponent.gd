extends Node
class_name AffectionComponent
var char_body: CharacterBody2D

func _ready() -> void:
	if get_parent(): char_body = get_parent()

func _process(delta: float) -> void:
	_connect_signals()

func _connect_signals():
	pass

var affection_meter = 0
@export var max_aff: int = 100
var current_aff: int = 0

signal ascend(body)
func _on_affect(actor, aff: int):
	if current_aff >= max_aff: return
	var previous_aff = current_aff
	current_aff = clamp(current_aff + aff, 0, max_aff)
	
	if abs(aff) > 0:
		if current_aff < previous_aff: print("%s#%s decrease %s AFF to %s#%s" % [actor.name, actor.base.id, previous_aff - current_aff, name, char_body.base.id])
		elif current_aff > previous_aff: print("%s#%s increase %s AFF to %s#%s" % [actor.name, actor.base.id, current_aff - previous_aff, name, char_body.base.id])
		if current_aff == previous_aff: print("No AFF change for %s#%s"% [name, char_body.base.id])
		print("%s#%s current AFF: %s" % [name, char_body.base.id, current_aff])
	if current_aff >= max_aff and !char_body.base.is_player:
		Con.c(self, "ascend", char_body, "_on_ascend")
		Con.c(self, "ascend", Stat.Gm, "_on_ascend")
		Con.c(self, "ascend", Stat.Player, "_on_ascend")
		emit_signal("ascend", char_body)
