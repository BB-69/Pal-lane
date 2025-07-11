extends Node
class_name AIComponent

var actions := {}
var previous_actions := {}
var just_actions := {}

func register_action(action: String):
	actions[action] = false
	previous_actions[action] = false
	just_actions[action] = false

func set_action(action: String, state: bool):
	if action in actions:
		actions[action] = state
	else:
		register_action(action)
		actions[action] = state

func update_actions():
	for action in actions.keys():
		var current = actions[action]
		var previous = previous_actions.get(action, false)
		just_actions[action] = current and not previous
		previous_actions[action] = current

func get_action(action: String) -> bool:
	return actions.get(action, false)

func get_action_just(action: String) -> bool:
	return just_actions.get(action, false)
