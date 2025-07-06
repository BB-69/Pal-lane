extends Camera2D

func _process(delta: float) -> void:
	Stat.Camera = get_viewport().get_camera_2d()
	Stat.Screen["Size"] = Vector2(
		get_viewport_rect().size.x * (0.5/zoom.x),
		get_viewport_rect().size.y * (0.5/zoom.y)
	)
	Stat.Screen["Center"] = Stat.Screen["Size"] + Stat.Camera.position
