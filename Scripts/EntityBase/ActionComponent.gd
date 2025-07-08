extends Node
class_name ActionComponent
var char_body: CharacterBody2D

func get_action(action_name: String):
	for a in actions:
		if a.action_name == action_name: return a

@export var actions: Array[ActionData]

func _ready() -> void:
	if get_parent(): char_body = get_parent()
	
	init_action_time()

var time: float = 0.0
var action_time: Dictionary[String, float] = {}
@export var cooldowns: Dictionary[String, float] = {
	"Launch": 0.25,
	"Parry": 0.5,
}

func init_action_time():
	for action_name in cooldowns.keys():
		action_time[action_name] = 0.0

func process_action(delta):
	time += delta
	var action_names = cooldowns.keys()
	for action_name in action_names: if (time - action_time[action_name] > cooldowns[action_name]) and Input.is_action_just_pressed(action_name):
		action_time[action_name] = time
		if get_action(action_name): get_action(action_name).execute(char_body, {
			"rotation": 0
		})
