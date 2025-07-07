extends ActionData
class_name LaunchAction

@export var missile_scene: PackedScene

func execute(actor, params = {
	"rotation": 0
}):
	var missile = missile_scene.instantiate()
	missile.rotation_degrees = params["rotation"]
	var radius = GetShapeRadius.g(actor.col)
	
	missile.global_position = actor.global_position + (Vector2.UP * radius*1.5).rotated(missile.rotation_degrees)
	actor.get_parent().add_child(missile)
	print("%s#%s launched a missile#%s!" % [actor.name, actor.base.id, missile.base.id])
