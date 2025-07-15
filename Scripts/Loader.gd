extends CanvasLayer
class_name SceneLoader

var log = Logger.new("Scene")

var scene:Dictionary = {
	"": "res://Scenes/_empty.tscn",
	"Main": "res://Scenes/main.tscn",
	"Game": "res://Scenes/game.tscn",
	"Result": "res://Scenes/result.tscn",
}

@onready var fade_rect = $FadeRect
@onready var top_rect = $TopRect
@onready var bottom_rect = $BottomRect
@onready var initial_pos: Dictionary[String, Vector2] = {
	"top_rect": top_rect.position,
	"bottom_rect": bottom_rect.position,
	"center_rect": (top_rect.position + bottom_rect.position)/2,
}

@onready var loading_icon = $LoadingIcon

func _ready():
	fade_rect.hide()
	fade_rect.modulate.a = 0.0
	
	top_rect.hide()
	bottom_rect.hide()
	top_rect.modulate.a = 1.0
	bottom_rect.modulate.a = 1.0
	
	loading_icon.hide()
	change_scene("Main", 0.8, [false, true])

func _process(delta: float) -> void:
	_connect_signals()

signal sound(actor, sound_name)
func _connect_signals():
	if Stat.Aud: Con.c(self, "sound", Stat.Aud.audc, "_on_sound")

func slide_in(duration: float = 0.5):
	top_rect.position = initial_pos["top_rect"]
	bottom_rect.position = initial_pos["bottom_rect"]
	top_rect.size.y = 0.0
	bottom_rect.size.y = 0.0
	top_rect.show()
	bottom_rect.show()
	
	var tween = create_tween()
	tween.tween_property(
		top_rect, "size:y", abs(initial_pos["center_rect"].y-initial_pos["top_rect"].y), duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(
		bottom_rect, "size:y", abs(initial_pos["bottom_rect"].y-initial_pos["center_rect"].y), duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(
		bottom_rect, "position:y", initial_pos["center_rect"].y, duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

func slide_out(duration: float = 0.5):
	top_rect.position = initial_pos["top_rect"]
	bottom_rect.position = initial_pos["center_rect"]
	top_rect.size.y = abs(initial_pos["center_rect"].y-initial_pos["top_rect"].y)
	bottom_rect.size.y = abs(initial_pos["bottom_rect"].y-initial_pos["center_rect"].y)
	top_rect.show()
	bottom_rect.show()
	
	var tween = create_tween()
	tween.tween_property(
		top_rect, "size:y", 0.0, duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(
		bottom_rect, "size:y", 0.0, duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(
		bottom_rect, "position:y", initial_pos["bottom_rect"].y, duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	top_rect.hide()
	bottom_rect.hide()

func fade_in(node: Variant, duration: float = 0.5, black_white: int = -1):
	if black_white >= 0 and black_white <= 1:
		node.modulate.r = 1.0 if black_white == 1 else 0.0
		node.modulate.g = 1.0 if black_white == 1 else 0.0
		node.modulate.b = 1.0 if black_white == 1 else 0.0
	node.show()
	node.modulate.a = 1.0
	node.create_tween().tween_property(
		node,
		"modulate:a",
		0.0,
		duration).finished.connect(
			func(): node.hide(),
		)

func fade_out(node: Variant, duration: float = 0.5, black_white: int = -1):
	if black_white >= 0 and black_white <= 1:
		node.modulate.r = 1.0 if black_white == 1 else 0.0
		node.modulate.g = 1.0 if black_white == 1 else 0.0
		node.modulate.b = 1.0 if black_white == 1 else 0.0
	node.show()
	node.modulate.a = 0.0
	node.create_tween().tween_property(
		node,
		"modulate:a",
		1.0,
		duration
	)

var change_scene_index = 0
func change_scene(set_scene: String, duration: float = 0.5, slides: Array = [true, true], has_load_icon: bool = true):
	if Stat.loading: return
	var scene_path = scene[set_scene]
	Stat.set_loading(true)
	
	emit_signal("sound", self, "gameover")
	slide_in(duration if slides[0] == true else 0)
	await get_tree().create_timer(duration).timeout
	if has_load_icon:
		fade_out(loading_icon, duration/2.0 if slides[0] == true or slides[1] == true else 0)
		await get_tree().create_timer(duration/2.0).timeout
	await get_tree().change_scene_to_file(scene_path)
	print("\n-------------CHANGE_SCENE_#%s-------------\n" % change_scene_index)
	change_scene_index += 1
	if set_scene == "":
		await get_tree().create_timer(0.1).timeout
		log.p("Quitting Game!")
		get_tree().quit()
		return
	else:
		log.p("Loaded %s scene!" % set_scene)
	if has_load_icon:
		fade_in(loading_icon, duration/2.0 if slides[1] == true else 0)
		await get_tree().create_timer(duration/2.0).timeout
	emit_signal("sound", self, "sweepup")
	slide_out(duration if slides[1] == true else 0)
	await get_tree().create_timer(duration).timeout
	
	Stat.set_loading(false)
