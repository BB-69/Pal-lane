extends AIComponent
class_name EnemyAIComponent
var char_body: CharacterBody2D

func _ready() -> void:
	if get_parent(): char_body = get_parent()
	
	register_action("Move_Left")
	register_action("Move_Right")
	register_action("Move_Up")
	register_action("Move_Down")

func _update(delta):
	update_actions()
	
	move()
	launch(delta)

var position_threshold = 125
var moving: bool = false
func move():
	if Stat.Player and Stat.Player.hp.current_hp > 0 and char_body and !moving:
		moving = true
		set_action("Move_Left", Stat.Player.position.x < char_body.position.x - position_threshold)
		set_action("Move_Right", Stat.Player.position.x > char_body.position.x + position_threshold)
		await get_tree().create_timer(0.5).timeout
		moving = false
	else:
		set_action("Move_Left", false)
		set_action("Move_Right", false)

var launching: bool = false
var launch_timer = 0
var launch_warmup = 0.5
func launch(delta):
	if Stat.Player and Stat.Player.hp.current_hp > 0 and char_body and abs(Stat.Player.position.x - char_body.position.x) < position_threshold:
		launch_timer += delta
		if launch_timer > launch_warmup and !launching:
			launching = true
			var rand = randi_range(0, 100)
			char_body.current_projectile_type = "Normal" if rand < 70 else "Golden"
			
			char_body.act.get_action("Launch").missile_storage.total_missile[char_body.current_projectile_type] = 10
			await get_tree().process_frame
			set_action("Launch", true)
			await get_tree().process_frame
			set_action("Launch", false)
			while get_tree() and !char_body.act.can_action("Launch"): await get_tree().process_frame
			launching = false
	else:
		launch_timer = 0
		set_action("Launch", false)
