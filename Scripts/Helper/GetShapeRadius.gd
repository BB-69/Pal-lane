extends Node

func g(collision_shape: CollisionShape2D) -> float:
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		return shape.radius
	elif shape is RectangleShape2D:
		return max(shape.extents.x, shape.extents.y)
	elif shape is CapsuleShape2D:
		return shape.radius
	else:
		return 0.0  # Not supported shape
