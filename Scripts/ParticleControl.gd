extends Node
class_name ParticleController
var ptc: ParticleManager

var log= Logger.new("Particle")

func _ready() -> void:
	if get_parent() is ParticleManager: ptc = get_parent()
	else: log.err("Parent of this node is not 'ParticleManager'!")

func _process(delta: float) -> void:
	pass

func _on_shockwave(obj):
	var particle = ptc.get_particle("shockwave")
	particle.global_position = obj.global_position
	ptc.group_emit_particle(particle)

func _on_fast_collision(obj):
	var particle = ptc.get_particle("fast_collision")
	particle.global_position = obj.global_position
	particle.rotation = obj.rotation
	ptc.group_emit_particle(particle)

func _on_heart_swirl(obj):
	var particle = ptc.get_particle("heart_swirl")
	particle.global_position = obj.global_position
	ptc.group_emit_particle(particle)

func _on_slash(obj):
	var particle = ptc.get_particle("slash")
	particle.global_position = obj.global_position
	particle.rotation_degrees = -45.0
	
	ptc.set_particle_childs(particle, true)
	var tween = create_tween()
	tween.tween_property(particle, "rotation_degrees", 45.0, 0.2)
	await tween.finished
	await get_tree().create_timer(0.1).timeout
	ptc.set_particle_childs(particle, false)
