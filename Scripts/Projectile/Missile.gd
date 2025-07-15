extends CharacterBody2D
class_name ProjectileClass
@export var base: BaseComponent
@export var pmov: ProjectileMovementComponent
@export var aspr: AnimatedSprite2D
@export var col: CollisionShape2D
@export var hurt: Area2D

var sender: CharacterBody2D = null
var stat_path: Dictionary = {
	"Normal": load("res://Resources/Projectile/Normal.tres"),
	"Golden": load("res://Resources/Projectile/Golden.tres"),
	"Love": load("res://Resources/Projectile/Love.tres"),
}
@export var stat: ProjectileData

func _enter_tree() -> void:
	_init_statics()
	
	init(null, stat.type)

func _physics_process(delta: float) -> void:
	_update_statistics()
	
	pmov._physics_update(delta)
	move_and_slide()
	check_collision()
	
	exhaust_flame_speed()

func init(from: CharacterBody2D, type: String):
	name = "Missile"
	sender = from
	stat = stat_path[type]
	pmov._ready()
	init_sprite(type)
func init_sprite(animation_name: String): aspr.animation = animation_name

var has_parried: bool = false
func _on_parry(actor: CharacterBody2D):
	if has_parried: return
	has_parried = true
	if actor is CharacterBody2D: sender = actor
	
	match actor.base.tag:
		"Player":
			if abs(ShortestAngleTo.a(0, rotation_degrees)) > 90:
				rotation_degrees = fmod(rotation_degrees + 180, 360)
			else:
				rotation_degrees = 0
				has_parried = false
			
		"Enemy":
			if abs(ShortestAngleTo.a(180, rotation_degrees)) > 90:
				rotation_degrees = fmod(rotation_degrees + 180, 360)
			else:
				rotation_degrees = 180
				has_parried = false
		
		_:
			has_parried = false
			return
	
	if has_parried:
		if stat.type == "Golden": init(actor, "Love")
		print("%s#%s parried a %s#%s!" % [actor.name, actor.base.id, name, base.id])

signal damage(actor, dmg: int)
signal affect(actor, aff: int)
signal fast_collision(actor)
signal heart_swirl(actor)
func check_collision():
	var collided = hurt.get_overlapping_bodies()
	var players: Array = []
	var enemies: Array = []
	for body in collided:
		if body.base: if body.base.tag == "Player": players.append(body)
		if body.base: if body.base.tag == "Enemy": enemies.append(body)
	
	var actor = sender if sender != null else self
	var entities: Array = [] + players + enemies #players if actor.base.tag != "Player" else (enemies if actor.base.tag != "Enemy" else [])
	if entities.is_empty(): return
	
	entities.erase(actor)
	for body in entities:
		if "hp" in body: Con.c(self, "damage", body.hp, "_on_damage")
		if "aff" in body: Con.c(self, "affect", body.aff, "_on_affect")
	emit_signal("damage", actor, stat.damage)
	emit_signal("affect", actor, stat.affection_point)
	
	if stat.type == "Love":
		Con.c(self, "heart_swirl", Stat.Ptc.ptcc, "_on_heart_swirl")
		emit_signal("heart_swirl", self)
	else:
		Con.c(self, "fast_collision", Stat.Ptc.ptcc, "_on_fast_collision")
		emit_signal("fast_collision", self)
	emit_signal("sound", self, "clash")
	
	
	Stat.Projectile.erase(base.id)
	if Stat.Gm: Stat.Gm.missile_pooler.release_instance(self)

@export_group("Visual")
@export var exhaust_flame_ptc: CPUParticles2D
func exhaust_flame_speed():
	var multipler = stat.acceleration/300.0
	exhaust_flame_ptc.lifetime = (multipler * 0.3) + 0.2
	if exhaust_flame_ptc.amount != int(multipler * 4) + 4:
		exhaust_flame_ptc.amount = int(multipler * 4) + 4
	exhaust_flame_ptc.initial_velocity_max = multipler * 240.0
	exhaust_flame_ptc.initial_velocity_min = exhaust_flame_ptc.initial_velocity_max * 0.75
	exhaust_flame_ptc.emitting = true





# =============== Statistics ===============
func _init_statics():
	Stat.Projectile[base.id] = self

func _update_statistics():
	_connect_signals()

signal sound(actor, sound_name)
func _connect_signals():
	Con.c(self, "sound", Stat.Aud.audc, "_on_sound")
