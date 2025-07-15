extends AnimatedSprite2D
class_name AnimatedSpriteComponent
var char_body: CharacterBody2D

var sprite

func _ready() -> void:
	if get_parent(): char_body = get_parent()
	
	sprite = self

func _process(delta: float) -> void:
	_connect_signals()

func _connect_signals():
	pass

const blink_shader = preload("res://Shaders/blink.gdshader")
var blinking: bool = false
var blink_delay: Timer
var blink_tween: Tween
func _on_blink(color:Color, duration:float=0.5, delay:float=0.0):
	if blinking: return
	blinking = true
	if blink_delay and !blink_delay.is_stopped(): blink_delay.stop()
	if blink_tween: blink_tween.kill()
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = blink_shader
	shader_material.set_shader_parameter("blink_color", color)
	sprite.material = shader_material
	
	if delay > 0:
		_set_blink(1)
		blink_delay = Timer.new()
		add_child(blink_delay)
		blink_delay.one_shot = true
		blink_delay.start(delay)
		await blink_delay.timeout
	
	blink_tween = get_tree().create_tween()
	blink_tween.tween_method(_set_blink, 1.0, 0.0, duration)
	await blink_tween.finished
	blinking = false
func _set_blink(value): sprite.material.set_shader_parameter("blink_intensity", value)
