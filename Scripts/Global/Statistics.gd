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
var Player: PlayerClass
# { id : self }
var Enemy: Dictionary = {}
var Projectile: Dictionary = {}

# === Data ===
var score: int

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_connect_signals()
	_set_data_live()
	
	check_is_offscreen()

var signal_connected:= false
func _connect_signals():
	Con.c(Gm, "add_score", Sc, "add_score")
	Con.c(Player, "game_over", Gm, "game_over")
	for e in Enemy.values():
		Con.c(e, "game_over", Gm, "game_over")
		Con.c(e, "ascend", Player, "_on_ascend")
		Con.c(e, "ascend", Gm, "_on_ascend")

func set_loading(loading:bool): self.loading = loading

func _set_data_live():
	if Sc: score = Sc.score

func is_offscreen(obj) -> bool:
	if !(Camera and obj): return false
	if abs(obj.global_position.x - Camera.global_position.x) > Screen["Size"].x*2 + 256:
		return true
	if abs(obj.global_position.y - Camera.global_position.y) > Screen["Size"].y*2 + 256:
		return true
	return false
func check_is_offscreen():
	for id in Projectile: if Gm and is_offscreen(Projectile[id]):
		Gm.missile_pooler.release_instance(Projectile[id])
		Projectile.erase(id)





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
