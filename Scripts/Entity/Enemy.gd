extends CharacterBody2D
class_name EnemyClass
@export var base: BaseComponent
@export var ai: EnemyAIComponent
@export var mov: MovementComponent
@export var act: ActionComponent
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
	
	action_param_init()
	act.init_action_time()

func _physics_process(delta: float) -> void:
	_update_statistics()
	
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
	
	if abs(dmg) > 0 and current_hp != previous_hp:
		if current_hp < previous_hp: print("%s#%s dealt %s DMG to %s#%s" % [actor.name, actor.base.id, previous_hp - current_hp, name, base.id])
		elif current_hp > previous_hp: print("%s#%s healed %s HP to %s#%s" % [actor.name, actor.base.id, current_hp - previous_hp, name, base.id])
		print("%s#%s current HP: %s" % [name, base.id, current_hp])
	if current_hp <= 0: emit_signal("game_over")

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
	if current_aff >= max_aff: emit_signal("ascend", self)

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
