extends Node
class_name GameManager

var log = Logger.new("Game")

var missile_pooler = Pooler.new("res://Scenes/Projectile/missile.tscn", 5, true, 10.0, 0.0)
var enemy_pooler = Pooler.new("res://Scenes/Entity/enemy.tscn", 3, true, 10.0, 0.0)
var spawn_timer = 0.0
var spawn_interval = 3.0
@export var center_offset_y: float = 0.0
@export var lane_positions: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]

var fever_gauge = 0
signal fever_started()
signal fever_ended()
var max_lane = 3

func _ready():
	Stat.Gm = self
	
	waited = false
	Stat.Enemy.clear()
	enemy_pooler.init(self)
	add_child(enemy_pooler)

func _process(delta: float) -> void:
	_connect_signals()
	wait()
	
	update_health_bar()
	update_label_text(delta)
	
	spawner(delta)

signal sound(actor, sound_name)
func _connect_signals():
	Con.c(self, "sound", Stat.Aud.audc, "_on_sound")

var game_started: bool = false
var waited: bool = false
func wait():
	if !waited: await get_tree().create_timer(0.5).timeout
	waited = true
	game_started = true

func spawner(delta):
	if !Stat.Player or Stat.Player == null:
		var player: PlayerClass = preload("res://Scenes/Entity/player.tscn").instantiate()
		add_child(player)
		player.name = "Player"
		print("Spawned %s#%s!" % [player.name, player.base.id])
		player.Game = self
		player.mov.move_lane(1.0/player.mov.speed, 2)
	
	if !Stat.Enemy.is_empty(): return
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		var enemy: EnemyClass = enemy_pooler.get_instance()
		enemy.name = "Enemy"
		print("Spawned %s#%s!" % [enemy.name, enemy.base.id])
		enemy.Game = self
		enemy.mov.move_lane(1.0/enemy.mov.speed, 2)
		enemy.rotation_degrees = 180

func _on_ascend(body: CharacterBody2D):
	Stat.Enemy.erase(body.base.id)
	enemy_pooler.release_instance(body)

signal add_score(score)
func _unhandled_input(event):
	if Stat.loading: return
	
	if event.is_action_pressed("ui_accept"):
		emit_signal("add_score", 1)
	elif Input.is_action_just_pressed("ui_cancel"):
		save_data()
		game_over()

@export_group("UI")
@export var health_bar: ValueBar
func update_health_bar():
	if !Stat.Player: return
	health_bar.value_current = Stat.Player.hp.current_hp
	health_bar.value_max = Stat.Player.hp.max_hp

var time_lapsed: float = 0.0
@export var time_lapsed_label: Label
@export var total_pal_label: Label
@export var total_love_missile_label: Label
var total_pal: int = 0
var total_love_missile: int = 0
func update_label_text(delta):
	if !Stat.Player or (Stat.Enemy.is_empty() and !game_started): return
	
	time_lapsed += delta
	time_lapsed_label.text = "Time Lapsed: %s" % TimeFormat.t(time_lapsed)
	
	if total_pal < Stat.Player.total_pal:
		if Stat.Aud: Stat.Aud.audc._on_sound(self, "pickup")
		total_pal = Stat.Player.total_pal
		total_pal_label.text = "Pals: %s" % total_pal
		total_pal_label.modulate.r = 0.2
		total_pal_label.modulate.b = 0.2
		var tween = create_tween()
		tween.tween_property(total_pal_label,"modulate:r",1.0,0.3)
		tween.parallel().tween_property(total_pal_label,"modulate:b",1.0,0.3)
	
	if total_love_missile < Stat.Player.act.get_action("Launch").missile_storage.total_missile["Love"]:
		total_love_missile = Stat.Player.act.get_action("Launch").missile_storage.total_missile["Love"]
		total_love_missile_label.text = "Love Missiles: %s" % total_love_missile
		total_love_missile_label.modulate.r = 0.2
		total_love_missile_label.modulate.b = 0.2
		var tween = create_tween()
		tween.tween_property(total_love_missile_label,"modulate:r",1.0,0.3)
		tween.parallel().tween_property(total_love_missile_label,"modulate:b",1.0,0.3)
	elif total_love_missile > Stat.Player.act.get_action("Launch").missile_storage.total_missile["Love"]:
		total_love_missile = Stat.Player.act.get_action("Launch").missile_storage.total_missile["Love"]
		total_love_missile_label.text = "Love Missiles: %s" % total_love_missile
		total_love_missile_label.modulate.g = 0.2
		total_love_missile_label.modulate.b = 0.2
		var tween = create_tween()
		tween.tween_property(total_love_missile_label,"modulate:g",1.0,0.3)
		tween.parallel().tween_property(total_love_missile_label,"modulate:b",1.0,0.3)

func game_over():
	save_data()
	var player = Stat.Player
	Stat.Player = null
	player.queue_free()
	for e in Stat.Enemy:
		var enemy = Stat.Enemy[e]
		Stat.Enemy.erase(e)
		enemy.queue_free()
	Stat.Enemy.clear()
	for m in missile_pooler.active_instances:
		missile_pooler.release_instance(m)
	Stat.Gm = null
	await Loader.change_scene("Result")





func save_data():
	var d = DataTemplate.new(
		Stat.Player.total_pal,
		time_lapsed,
	)
	Data.save_data(d.data)
