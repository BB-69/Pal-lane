extends Node
class_name GameManager

var log = Logger.new("Game")

var fever_gauge = 0
signal fever_started()
signal fever_ended()
var max_lane = 3

func _ready():
	Stat.Gm = self

signal add_score(score)

func _unhandled_input(event):
	if Stat.loading: return
	
	if event.is_action_pressed("ui_accept"):
		emit_signal("add_score", 1)
	elif Input.is_action_just_pressed("ui_cancel"):
		save_data()
		await Loader.change_scene("Result")

func save_data():
	var d = DataTemplate.new(
		Stat.score
	)
	Data.save_data(d.data)
