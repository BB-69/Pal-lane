extends Node2D
class_name PlayerClass
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

@export var parry_cooldown = 0.5
@export var max_hp = 5

var current_hp = max_hp
var affection_meter = 0
var stored_love_projectiles = 0
var buff_stacks = 0

func _ready() -> void:
	_init_statics()

func _physics_process(delta: float) -> void:
	_update_statistics()





# =============== Statistics ===============
func _init_statics():
	Stat.Player = self

func _update_statistics():
	_connect_signals()

var signal_connected:= false
func _connect_signals():
	pass
