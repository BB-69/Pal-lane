extends Node
class_name ActionComponent
var char_body: CharacterBody2D

func get_action(action_name: String) -> ActionData:
	for a in actions:
		if a.action_name == action_name: return a
	return null

func execute_action(action_name: String):
	if get_action(action_name) != null:
		var params: Dictionary = {}
		if char_body.action_param.has(action_name): params = char_body.action_param[action_name]
		get_action(action_name).execute(char_body, params)

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
	var all_action_names: Array[String] = []
	for a in actions:
		all_action_names.append(a.action_name)
	var noCD_action_names = all_action_names
	
	var action_names = cooldowns.keys()
	for action_name in action_names:
		if noCD_action_names.has(action_name): noCD_action_names.erase(action_name)
		if can_action(action_name) and char_body.input(action_name, true):
				action_time[action_name] = time
				execute_action(action_name)
	for action_name in noCD_action_names:
		execute_action(action_name)

func can_action(action_name):
	return time - action_time[action_name] > cooldowns[action_name]
