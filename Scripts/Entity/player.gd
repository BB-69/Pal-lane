extends CharacterBody2D
class_name PlayerClass
@export var base: BaseComponent
@export var mov: MovementComponent
@export var act: ActionComponent
@export var hp: HealthComponent

@export var aspr: AnimatedSprite2D
@export var col: CollisionShape2D
@export var hurt: Area2D

@export var Game: GameManager

# Inputs
func input(action_name: String, continuous_press: bool):
	if !continuous_press: return Input.is_action_just_pressed(action_name)
	else: return Input.is_action_pressed(action_name)

func get_input(continuous_press: bool):
	match continuous_press:
		true: return {
			"Move_Left"	: Input.is_action_pressed("Move_Left"),
			"Move_Right": Input.is_action_pressed("Move_Right"),
			"Move_Up"	: Input.is_action_pressed("Move_Up"),
		}
		false: return {
			"Move_Left"	: Input.is_action_just_pressed("Move_Left"),
			"Move_Right": Input.is_action_just_pressed("Move_Right"),
			"Move_Up"	: Input.is_action_just_pressed("Move_Up"),
		}
		_: return null

@export_group("Stat")
@export var current_projectile_type = "Love"

func _ready() -> void:
	_init_statics()
	spawning()
	
	action_param_init()
	act.init_action_time()
	
	hp.execute_hp_overtime(1, 1.0)

var finished_spawning: bool = false
func spawning():
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 1.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT
		).finished.connect(func(): spawned())
func spawned(): finished_spawning = true

var initialized_missile
func init_missile():
	if Stat.Enemy.is_empty() or initialized_missile: return
	initialized_missile = true
	act.get_action("Launch").missile_storage.total_missile["Love"] = 8

func _physics_process(delta: float) -> void:
	_update_statistics()
	init_missile()
	
	mov._physics_update(delta)
	move_and_slide()
	
	act.process_action(delta)

@export_group("Action")
var action_param: Dictionary[String, Dictionary]
var launch_param: Dictionary[String, Variant] = {
	"type": "Love",
	"rotation": 0,
}
func action_param_init():
	action_param = {
		"Launch": launch_param,
	}

@export_group("Affection")
var total_pal: int = 0
var buff_stacks: int = 0

func _on_ascend(body: CharacterBody2D):
	total_pal += 1
	act.get_action("Launch").missile_storage.total_missile["Love"] += 5

@export_group("Game")
signal game_over






# =============== Statistics ===============
func _init_statics():
	Stat.Player = self

func _update_statistics():
	_connect_signals()

signal sound(actor, sound_name)
func _connect_signals():
	Con.c(self, "sound", Stat.Aud.audc, "_on_sound")
