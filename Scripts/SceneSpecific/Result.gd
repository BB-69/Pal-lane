extends Node
class_name ResultManager

var log = Logger.new("Result")

@export_group("Result Page")
@export var final_score_label: Label
@export var time_lapsed_label: Label

func _ready():
	Stat.Rs = self
	
	show_result()

func _unhandled_input(event):
	if Stat.loading: return
	
	if event.is_action_pressed("ui_accept"):
		if Stat.Aud: Stat.Aud.audc._on_sound(self, "confirm")
		await Loader.change_scene("Game")
	elif Input.is_action_just_pressed("ui_cancel"):
		if Stat.Aud: Stat.Aud.audc._on_sound(self, "confirm")
		await Loader.change_scene("Main")

func show_result():
	var d: Dictionary = Data.load_data()
	
	final_score_label.text = "Your Pal%s: %s" % ["s" if d["total_pal"] > 1 else "", d["total_pal"]]
	time_lapsed_label.text = "Time Lapsed: %s" % TimeFormat.t(d["time_lapsed"])
