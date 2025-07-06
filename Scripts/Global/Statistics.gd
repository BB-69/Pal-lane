extends Node

# === Object ===
var id_count: int = 0

# === Game ===
var Camera
var Screen: Dictionary = {
	"Center": Vector2.ZERO,
	"Size": Vector2.ZERO,
}
var loading: bool = false

# === Manager ===
var mngs = [Aud, Ptc, Ma, Gm, Sc]
var Aud: AudioManager
var Ptc: ParticleManager
var Ma: MainMenuManager
var Gm: GameManager
var Rs: ResultManager
var Sc: ScoreManager

# === Entity ===
var Player: Node2D
var Enemy: Array[Node2D] = []

# === Data ===
var score: int

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_connect_signals()
	_set_data_live()

var signal_connected:= false
func _connect_signals():
	Con.c(Gm, "add_score", Sc, "add_score")

func set_loading(loading:bool): self.loading = loading

func _set_data_live():
	if Sc: score = Sc.score

func is_offscreen(obj) -> bool:
	if !Camera: return false
	if abs(obj.global_position.x - Camera.global_position.x) > Screen["Size"].x + 256:
		return true
	if abs(obj.global_position.y - Camera.global_position.y) > Screen["Size"].y + 256:
		return true
	return false





# =============== Game State ===============
enum GameState {Idle, Ongoing, Gameover}
const game_scene = preload("res://Scenes/game.tscn")

func _on_gameover():
	reset()
	Loader.change_scene("Result")

func reset():
	id_count = 0
	
	Camera = null
	Screen["Center"] = Vector2.ZERO
	Screen["Size"] = Vector2.ZERO
	
	for mng in mngs: if mng: mng.queue_free()
	
	signal_connected = false
