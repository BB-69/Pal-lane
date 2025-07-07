extends Node
class_name ActionComponent
var char_body: CharacterBody2D

func get_action(action_name: String):
	for a in actions:
		if a.action_name == action_name: return a

@export var actions: Array[ActionData]

func _ready() -> void:
	if get_parent(): char_body = get_parent()
