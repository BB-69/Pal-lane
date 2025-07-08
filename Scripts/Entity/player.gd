extends CharacterBody2D
class_name PlayerClass
@export var base: BaseComponent
@export var mov: MovementComponent
@export var act: ActionComponent
@export var col: CollisionShape2D
@export var hurt: Area2D

@export var Game: GameManager

# Inputs
func get_input(continuous_press:bool):
	match continuous_press:
		true: return {
			"move_left"	: Input.is_action_pressed("Move-Left"),
			"move_right": Input.is_action_pressed("Move-Right"),
			"move_up"	: Input.is_action_pressed("Move-Up"),
		}
		false: return {
			"move_left"	: Input.is_action_just_pressed("Move-Left"),
			"move_right": Input.is_action_just_pressed("Move-Right"),
			"move_up"	: Input.is_action_just_pressed("Move-Up"),
		}
		_: return null

@export_group("Stat")
@export var max_hp = 5

var current_hp = max_hp
var affection_meter = 0
var stored_love_projectiles = 0
var buff_stacks = 0

func _ready() -> void:
	_init_statics()
	
	init_action_time()

func _physics_process(delta: float) -> void:
	_update_statistics()
	
	mov._physics_update(delta)
	move_and_slide()
	
	process_action(delta)

@export_group("Action")
var time: float = 0.0
var action_time: Dictionary[String, float] = {}
@export var cooldowns: Dictionary[String, float] = {
	"Launch": 0.25,
	"Parry": 0.5,
}
@export var total_missile: ProjectileStorage

func init_action_time():
	for action_name in cooldowns.keys():
		action_time[action_name] = 0.0

func process_action(delta):
	time += delta
	var action_names = cooldowns.keys()
	for action_name in action_names: if (time - action_time[action_name] > cooldowns[action_name]) and Input.is_action_just_pressed(action_name):
		action_time[action_name] = time
		act.get_action(action_name).execute(self, {
			"rotation": 0
		})





# =============== Statistics ===============
func _init_statics():
	Stat.Player = self

func _update_statistics():
	_connect_signals()

var signal_connected:= false
func _connect_signals():
	pass
