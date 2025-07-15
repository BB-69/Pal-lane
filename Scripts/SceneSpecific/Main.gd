extends Node2D
class_name MainMenuManager

var log = Logger.new("Main")

@export var bg: BGManager
@export var info_label: Label
var label_tween: Tween

func _ready():
	Stat.Ma = self
	
	info_label.show()
	info_label.modulate.a = 1.0
	label_tween = fade_in(info_label, 4.0)

func _process(delta: float) -> void:
	_connect_signals()

signal sound(actor, sound_name)
func _connect_signals():
	Con.c(self, "sound", Stat.Aud.audc, "_on_sound")

var changing_scene: bool = false
func _unhandled_input(event):
	if Stat.loading or changing_scene: return
	
	if event.is_action_pressed("ui_accept"):
		changing_scene = true
		
		emit_signal("sound", self, "confirm")
		emit_signal("sound", self, "powerup-2")
		if event.is_action_pressed("Space"):
			info_label.text = "Press [Space] to Start"
		label_tween.kill()
		blink(info_label, 0.07)
		Loader.fade_in(Loader.fade_rect, 0.7, 1)
		await get_tree().create_timer(1.2).timeout
		emit_signal("sound", self, "gameover")
		await Loader.change_scene("Game")
	elif Input.is_action_just_pressed("ui_cancel"):
		changing_scene = true
		
		emit_signal("sound", self, "confirm")
		emit_signal("sound", self, "powerup-2")
		info_label.text = "Press [Esc] to Quit"
		label_tween.kill()
		blink(info_label, 0.25)
		Loader.fade_in(Loader.fade_rect, 0.7, 1)
		
		var new_texture = GradientTexture1D.new()
		var new_gradient = Gradient.new()
		new_gradient.colors = [Color(0.5,0.5,0.5)]
		new_texture.gradient = new_gradient
		bg.bg_texture = new_texture
		
		await get_tree().create_timer(1.5).timeout
		await Loader.change_scene("", 1.0, [true, false], false)

func fade_out(node: Variant, duration: float = 0.5, black_white: int = -1) -> Tween:
	if black_white >= 0 and black_white <= 1:
		node.modulate.r = 1.0 if black_white == 1 else 0.0
		node.modulate.g = 1.0 if black_white == 1 else 0.0
		node.modulate.b = 1.0 if black_white == 1 else 0.0
	node.show()
	node.modulate.a = 1.0
	var tween = node.create_tween()
	tween.tween_property(
		node,
		"modulate:a",
		0.0,
		duration).finished.connect(
			func(): node.hide(),
		)
	return tween

func fade_in(node: Variant, duration: float = 0.5, black_white: int = -1) -> Tween:
	if black_white >= 0 and black_white <= 1:
		node.modulate.r = 1.0 if black_white == 1 else 0.0
		node.modulate.g = 1.0 if black_white == 1 else 0.0
		node.modulate.b = 1.0 if black_white == 1 else 0.0
	node.show()
	node.modulate.a = 0.0
	var tween = node.create_tween()
	tween.tween_property(
		node,
		"modulate:a",
		1.0,
		duration
	)
	return tween

func blink(node: Variant, interval: float = 0.07, iteration: int = 0):
	node.modulate.a = 1.0
	node.hide()
	if get_tree(): await get_tree().create_timer(interval/2).timeout
	node.modulate.a = 1.0
	node.show()
	if get_tree(): await get_tree().create_timer(interval/2).timeout
	if iteration > 1: blink(node, interval, iteration-1)
	elif iteration <= 0 and get_tree(): blink(node, interval, iteration)
