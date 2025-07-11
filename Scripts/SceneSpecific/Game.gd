extends Node
class_name GameManager

var log = Logger.new("Game")

var missile_pooler = Pooler.new("res://Scenes/Projectile/missile.tscn", 5, true, 10.0, 0.0)
var enemy_pooler = Pooler.new("res://Scenes/Entity/enemy.tscn", 3, true, 10.0, 0.0)
var spawn_timer = 0.0
var spawn_interval = 2.0
@export var center_offset_y: float = 0.0
@export var lane_positions: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]

var fever_gauge = 0
signal fever_started()
signal fever_ended()
var max_lane = 3

func _ready():
	Stat.Gm = self
	
	enemy_pooler.init(self)
	add_child(enemy_pooler)

func _process(delta: float) -> void:
	update_health_bar()
	update_label_text(delta)
	spawner(delta)

func spawner(delta):
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
		await Loader.change_scene("Result")

@export_group("UI")
@export var health_bar: ValueBar
func update_health_bar():
	health_bar.value_current = Stat.Player.current_hp
	health_bar.value_max = Stat.Player.max_hp

var time_lapsed: float = 0.0
@export var time_lapsed_label: Label
@export var total_pal_label: Label
func update_label_text(delta):
	time_lapsed += delta
	time_lapsed_label.text = "Time Lapsed: %s" % TimeFormat.t(time_lapsed)
	total_pal_label.text = "Pal: %s" % Stat.Player.total_pal

func game_over():
	save_data()
	await Loader.change_scene("Result")





func save_data():
	var d = DataTemplate.new(
		Stat.Player.total_pal,
		time_lapsed,
	)
	Data.save_data(d.data)
