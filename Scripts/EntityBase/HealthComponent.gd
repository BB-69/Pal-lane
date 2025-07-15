extends Node
class_name HealthComponent
var char_body: CharacterBody2D

@export var max_hp: int = 100
@onready var current_hp: int = max_hp

func _ready() -> void:
	if get_parent(): char_body = get_parent()

func _process(delta: float) -> void:
	_connect_signals()

signal blink(actor, color, duration, delay)
signal sound(actor, sound_name)
signal game_over()
func _connect_signals():
	Con.c(self, "blink", char_body.aspr, "_on_blink")
	Con.c(self, "sound", Stat.Aud.audc, "_on_sound")
	Con.c(self, "game_over", Stat.Gm, "game_over")

func _on_damage(actor, dmg: int):
	if current_hp <= 0: return
	var previous_hp = current_hp
	current_hp = clamp(current_hp - dmg, 0, max_hp)
	
	emit_signal("blink", Color(1, 0.2, 0.2), 0.3, 0.1)
	emit_signal("sound", char_body, "hit")
	
	if abs(dmg) > 0 and current_hp != previous_hp:
		if current_hp < previous_hp: print("%s#%s dealt %s DMG to %s#%s" % [actor.name, actor.base.id, previous_hp - current_hp, name, char_body.base.id])
		elif current_hp > previous_hp: print("%s#%s healed %s HP to %s#%s" % [actor.name, actor.base.id, current_hp - previous_hp, name, char_body.base.id])
		print("%s#%s current HP: %s" % [name, char_body.base.id, current_hp])
	if current_hp <= 0: if char_body.base.is_player:
		emit_signal("game_over")

var do_hp_overtime: bool = false
func stop_hp_overtime(): do_hp_overtime = false
func execute_hp_overtime(amount: int, interval: float):
	do_hp_overtime = true
	hp_overtime(amount, interval)
func hp_overtime(amount: int, interval: float):
	current_hp += amount
	if get_tree(): await get_tree().create_timer(interval).timeout
	if get_tree() and do_hp_overtime: hp_overtime(amount, interval)
