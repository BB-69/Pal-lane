extends Resource
class_name ActionData
@export var action_name = "Unnamed"

func execute(actor, params = {}):
	print("%s Action..." % action_name)
