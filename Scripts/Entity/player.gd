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

func get_axis(input1:String, input2:String, continuous_press:bool) -> int:
	var axis:= 0
	if get_input(continuous_press)[input1]: axis -= 1
	if get_input(continuous_press)[input2]: axis += 1
	return axis

@export var speed = 20
@export var parry_cooldown = 0.5
@export var lane_positions : Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
@export var max_hp = 5

var _current_lane = 2
var current_lane:
	get: return _current_lane
	set(value):
		if Game: _current_lane = clamp(value, 1, Game.max_lane)
		else: _current_lane = 2
var current_hp = max_hp
var affection_meter = 0
var stored_love_projectiles = 0
var buff_stacks = 0

func _ready() -> void:
	_init_statics()

func _physics_process(delta: float) -> void:
	_update_statistics()
	
	var lane_change = get_axis("move_left", "move_right", false)
	current_lane += lane_change*2 if Input.is_action_pressed("Move-Boost") else lane_change
	move_lane(delta, current_lane)

func move_lane(delta, lane_num: int):
	var target_position = lane_positions[lane_num - 1]
	if (position.distance_to(target_position) > 10):
		position = lerp(position, Stat.Screen["Center"] + target_position, speed * delta)
	else:
		position = target_position





# =============== Statistics ===============
func _init_statics():
	Stat.Player = self

func _update_statistics():
	_connect_signals()

var signal_connected:= false
func _connect_signals():
	pass
