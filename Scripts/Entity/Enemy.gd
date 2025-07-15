extends CharacterBody2D
class_name EnemyClass
@export var base: BaseComponent
@export var ai: EnemyAIComponent
@export var mov: MovementComponent
@export var act: ActionComponent
@export var hp: HealthComponent
@export var aff: AffectionComponent

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

@export_group("Affection")
signal heart_explode(body)
func _on_ascend(body: CharacterBody2D):
	Con.c(self, "heart_explode", Stat.Ptc.ptcc, "_on_heart_explode")
	emit_signal("heart_explode", self)
	emit_signal("sound", self, "explosion")

@export_group("Game")
signal game_over






# =============== Statistics ===============
func _init_statics():
	Stat.Enemy[base.id] = self

func _update_statistics():
	_connect_signals()

signal sound(actor, sound_name)
func _connect_signals():
	Con.c(self, "sound", Stat.Aud.audc, "_on_sound")
