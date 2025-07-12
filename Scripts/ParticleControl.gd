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

func _on_heart_explode(obj):
	var particle = ptc.get_particle("heart_explode")
	particle.global_position = obj.global_position
	ptc.group_emit_particle(particle)

func _on_slash(obj):
	var particle = ptc.get_particle("slash")
	var p0 = particle.get_child(0)
	var p1 = particle.get_child(1)
	
	particle.global_position = obj.global_position
	p0.position.x = 0
	p1.position.x = 0
	p0.emitting = true
	p1.emitting = true
	var tween = create_tween()
	tween.tween_property(p0, "position:x", -75.0, 0.1)
	tween.parallel().tween_property(p1, "position:x", 75.0, 0.1)
	await tween.finished
	await get_tree().create_timer(0.05).timeout
	p0.emitting = false
	p1.emitting = false
