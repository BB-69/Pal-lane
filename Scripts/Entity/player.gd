extends CharacterBody2D
class_name PlayerClass
@export var base: BaseComponent
@export var mov: MovementComponent
@export var act: ActionComponent
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
	
	action_param_init()
	act.init_action_time()
	
	do_hp_overtime = true
	hp_overtime(1, 1.0)

func _physics_process(delta: float) -> void:
	_update_statistics()
	
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

@export_group("Health")
@export var max_hp: int = 100
@onready var current_hp: int = max_hp

func _on_damage(actor, dmg: int):
	if current_hp <= 0: return
	var previous_hp = current_hp
	current_hp = clamp(current_hp - dmg, 0, max_hp)
	
	if abs(dmg) > 0 and current_hp != previous_hp:
		if current_hp < previous_hp: print("%s#%s dealt %s DMG to %s#%s" % [actor.name, actor.base.id, previous_hp - current_hp, name, base.id])
		elif current_hp > previous_hp: print("%s#%s healed %s HP to %s#%s" % [actor.name, actor.base.id, current_hp - previous_hp, name, base.id])
		print("%s#%s current HP: %s" % [name, base.id, current_hp])
	if current_hp <= 0: emit_signal("game_over")

var do_hp_overtime: bool = false
func hp_overtime(amount: int, interval: float):
	current_hp += amount
	if get_tree(): await get_tree().create_timer(interval).timeout
	if get_tree() and do_hp_overtime: hp_overtime(amount, interval)

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

var signal_connected:= false
func _connect_signals():
	pass
