extends Node

func a(target: float, rotation_degrees) -> float:
	return fmod((target - rotation_degrees + 540), 360) - 180
