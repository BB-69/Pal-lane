extends CharacterBody2D
class_name EnemyClass
@export var base: BaseComponent
@export var ai: EnemyAIComponent
@export var mov: MovementComponent
@export var act: ActionComponent
@export var aspr: AnimatedSprite2D
@export var col: CollisionShape2D
@export var hurt: Area2D

@export var Game: GameManager

# Inputs
func input(action_name: String, continuous_press: bool):
	if !continuous_press: return ai.get_action_just(action_name)
	else: return ai.get_action(action_name)

func get_input(continuous_press: bool):
	match continuous_press:
		true: return {
			"Move_Left"	: ai.get_action("Move_Left"),
			"Move_Right": ai.get_action("Move_Right"),
			"Move_Up"	: ai.get_action("Move_Up"),
		}
		false: return {
			"Move_Left"	: ai.get_action_just("Move_Left"),
			"Move_Right": ai.get_action_just("Move_Right"),
			"Move_Up"	: ai.get_action_just("Move_Up"),
		}
		_: return null

@export_group("Stat")
@export var current_projectile_type = "Normal"

func _ready() -> void:
	_init_statics()
	spawning()
	
	action_param_init()
	act.init_action_time()

var finished_spawning: bool = false
func spawning():
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 1.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT
		).finished.connect(func(): spawned())
func spawned(): finished_spawning = true

func _physics_process(delta: float) -> void:
	_update_statistics()
	if !finished_spawning: return
	
	mov._physics_update(delta)
	move_and_slide()
	
	ai._update(delta)
	action_param_init()
	act.process_action(delta)

@export_group("Action")
var action_param: Dictionary[String, Dictionary]
var launch_param: Dictionary[String, Variant] = {
	"type": "Normal",
	"rotation": 180,
}
func action_param_init():
	launch_param["type"] = current_projectile_type
	
	action_param = {
		"Launch": launch_param,
	}

@export_group("Health")
@export var max_hp: int = 100
var current_hp: int = max_hp

func _on_damage(actor, dmg: int):
	if current_hp <= 0: return
	var previous_hp = current_hp
	current_hp = clamp(current_hp - dmg, 0, max_hp)
	
	blink(Color(1, 0.2, 0.2), 0.3, 0.1)
	if Stat.Aud: Stat.Aud.audc._on_sound(self, "hit")
	
	if abs(dmg) > 0 and current_hp != previous_hp:
		if current_hp < previous_hp: print("%s#%s dealt %s DMG to %s#%s" % [actor.name, actor.base.id, previous_hp - current_hp, name, base.id])
		elif current_hp > previous_hp: print("%s#%s healed %s HP to %s#%s" % [actor.name, actor.base.id, current_hp - previous_hp, name, base.id])
		print("%s#%s current HP: %s" % [name, base.id, current_hp])
	if current_hp <= 0: emit_signal("game_over")

const blink_shader = preload("res://Shaders/blink.gdshader")
var blink_delay: Timer
var blink_tween: Tween
func blink(color:Color, duration:float=0.5, delay:float=0.0):
	if blink_delay and !blink_delay.is_stopped(): blink_delay.stop()
	if blink_tween: blink_tween.kill()
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = blink_shader
	shader_material.set_shader_parameter("blink_color", color)
	aspr.material = shader_material
	
	if delay > 0:
		_set_blink(1)
		blink_delay = Timer.new()
		add_child(blink_delay)
		blink_delay.one_shot = true
		blink_delay.start(delay)
		await blink_delay.timeout
	
	blink_tween = get_tree().create_tween()
	blink_tween.tween_method(_set_blink, 1.0, 0.0, duration)
func _set_blink(value): aspr.material.set_shader_parameter("blink_intensity", value)

@export_group("Affection")
var affection_meter = 0
@export var max_aff: int = 100
var current_aff: int = 0

signal ascend(body)
func _on_affect(actor, aff: int):
	if current_aff >= max_aff: return
	var previous_aff = current_aff
	current_aff = clamp(current_aff + aff, 0, max_aff)
	
	if abs(aff) > 0:
		if current_aff < previous_aff: print("%s#%s decrease %s AFF to %s#%s" % [actor.name, actor.base.id, previous_aff - current_aff, name, base.id])
		elif current_aff > previous_aff: print("%s#%s increase %s AFF to %s#%s" % [actor.name, actor.base.id, current_aff - previous_aff, name, base.id])
		if current_aff == previous_aff: print("No AFF change for %s#%s"% [name, base.id])
		print("%s#%s current AFF: %s" % [name, base.id, current_aff])
	if current_aff >= max_aff:
		Con.c(self, "ascend", self, "_on_ascend")
		emit_signal("ascend", self)

signal heart_explode(body)
func _on_ascend(body: CharacterBody2D):
	Con.c(self, "heart_explode", Stat.Ptc.ptcc, "_on_heart_explode")
	emit_signal("heart_explode", self)
	if Stat.Aud: Stat.Aud.audc._on_sound(self, "explosion")

@export_group("Game")
signal game_over






# =============== Statistics ===============
func _init_statics():
	Stat.Enemy[base.id] = self

func _update_statistics():
	_connect_signals()

var signal_connected:= false
func _connect_signals():
	pass
