extends ActionData
class_name LaunchAction

@export var missile_scene: PackedScene
@export var missile_storage: ProjectileStorage

signal shockwave(actor)
func execute(actor, params = {
	"type": "Normal",
	"rotation": 0,
}):
	if !(missile_storage.total_missile[params["type"]] > 0):
		print("%s#%s tried to launch '%s' missile!" % [actor.name, actor.base.id, params["type"]])
		return
	missile_storage.total_missile[params["type"]] -= 1
	
	var missile = missile_scene.instantiate()
	missile.init(actor, params["type"])
	missile.rotation_degrees = params["rotation"]
	var radius = GetShapeRadius.g(actor.col)
	
	missile.global_position = actor.global_position + (Vector2.UP * radius*1.8).rotated(missile.rotation)
	Con.c(self, "shockwave", Stat.Ptc.ptcc, "_on_shockwave")
	emit_signal("shockwave", missile)
	if Stat.Aud: Stat.Aud.audc._on_sound(actor, "shoot")
	if Stat.Aud: Stat.Aud.audc._on_sound(actor, "launch")
	actor.get_parent().add_child(missile)
	print("%s#%s launched a %s#%s!" % [actor.name, actor.base.id, missile.name, missile.base.id])
