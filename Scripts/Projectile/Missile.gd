extends CharacterBody2D
class_name ProjectileClass
@export var base: BaseComponent
@export var pmov: ProjectileMovementComponent

@export var stat: ProjectileData

func _ready() -> void:
	_init_statics()

func _physics_process(delta: float) -> void:
	_update_statistics()
	
	pmov._physics_update(delta)
	move_and_slide()





# =============== Statistics ===============
func _init_statics():
	Stat.Player = self

func _update_statistics():
	_connect_signals()

var signal_connected:= false
func _connect_signals():
	pass
