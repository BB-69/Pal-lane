extends Node
class_name ProjectileMovementComponent
var missile: CharacterBody2D

var speed: float = 0.0
var max_speed: int = 250
var acceleration: int = 1000
var direction: Vector2 = Vector2.UP

func _ready() -> void:
	if get_parent():
		missile = get_parent()
		if missile.stat:
			speed = missile.stat.speed
			max_speed = missile.stat.max_speed
			acceleration = missile.stat.acceleration
	
	

func _physics_update(delta: float) -> void:
	speed += acceleration * delta
	speed = min(speed, max_speed)
	missile.velocity = (direction*speed).rotated(missile.rotation)
