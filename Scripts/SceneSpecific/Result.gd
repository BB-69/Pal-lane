extends Node
class_name ResultManager

var log = Logger.new("Result")

@export_group("Result Page")
@export var final_score_label: Label
@export var time_lapsed_label: Label

func _ready():
	Stat.Rs = self
	
	show_result()

func _process(delta: float) -> void:
	_connect_signals()

signal sound(actor, sound_name)
func _connect_signals():
	Con.c(self, "sound", Stat.Aud.audc, "_on_sound")

func _unhandled_input(event):
	if Stat.loading: return
	
	if event.is_action_pressed("ui_accept"):
		emit_signal("sound", self, "confirm")
		await Loader.change_scene("Game")
	elif Input.is_action_just_pressed("ui_cancel"):
		emit_signal("sound", self, "confirm")
		await Loader.change_scene("Main")

func show_result():
	var d: Dictionary = Data.load_data()
	
	final_score_label.text = "Your Pal%s: %s" % ["s" if d["total_pal"] > 1 else "", d["total_pal"]]
	time_lapsed_label.text = "Time Lapsed: %s" % TimeFormat.t(d["time_lapsed"])
