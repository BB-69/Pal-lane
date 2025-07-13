extends Node
class_name AudioController
var aud: AudioManager

var log = Logger.new("Audio")

func _ready() -> void:
	if get_parent() is AudioManager: aud = get_parent()
	else: log.err("Parent of this node is not 'AudioManager'!")

func _process(delta: float) -> void:
	pass

func _on_empty(target):
	var sound = aud.get_sound("empty")
	sound.global_position = target.global_position
	sound.play()

func _on_sound(obj, sound_name: String):
	var sound = aud.get_sound(sound_name)
	sound.global_position = Stat.Screen["Center"]
	aud.group_play_sound(sound)
