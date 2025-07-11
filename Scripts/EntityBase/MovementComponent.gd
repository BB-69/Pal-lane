extends Node
class_name MovementComponent
var char_body: CharacterBody2D

func get_axis(input1:String, input2:String, continuous_press:bool) -> int:
	var axis:= 0
	if char_body.get_input(continuous_press)[input1]: axis -= 1
	if char_body.get_input(continuous_press)[input2]: axis += 1
	return axis

@export var speed: float = 20.0
@export var center_offset_y: float = 0.0
@export var lane_positions: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]

var _current_lane = 2
var current_lane:
	get: return _current_lane
	set(value):
		if char_body.Game: _current_lane = clamp(value, 1, char_body.Game.max_lane)
		else: _current_lane = 2

func _ready() -> void:
	if get_parent(): char_body = get_parent()

var moving: bool = false
func _physics_update(delta: float) -> void:
	var lane_change = get_axis("Move_Left", "Move_Right", false) if !moving else 0
	current_lane += lane_change*2 if char_body.input("Move_Boost", true) else lane_change
	move_lane(delta, current_lane)

func move_lane(delta, lane_num: int):
	var target_lane_position = lane_positions[lane_num - 1]
	var target_position = Stat.Screen["Center"] + Vector2(0, center_offset_y) + target_lane_position
	if (char_body.position.distance_to(target_position) > 1):
		moving = true
		char_body.position = lerp(char_body.position, target_position, speed * delta)
	else:
		moving = false
		char_body.position = target_position
