extends Node
class_name Pooler

var scene_path: String
var initial_size: int
var auto_shrink: bool
var shrink_interval: float
var spawn_loop_interval: float

var parent_node: Node = null
var packed_scene: PackedScene
var temp_pool: Array = []
var pool: Array = []
var active_instances: Array = []

var spawn_timer: Timer
var shrink_timer: Timer

func _init(
	scene_path: String,
	initial_size: int = 5,
	auto_shrink: bool = true,
	shrink_interval: float = 10.0,
	spawn_loop_interval: float = 0.0
):
	self.scene_path = scene_path
	self.initial_size = initial_size
	self.auto_shrink = auto_shrink
	self.shrink_interval = shrink_interval
	self.spawn_loop_interval = spawn_loop_interval

func init(parent: Node):
	parent_node = parent
	packed_scene = load(scene_path)

	for i in initial_size:
		var inst = _create_instance()
		_return_to_pool(inst)

	if auto_shrink:
		shrink_timer = Timer.new()
		shrink_timer.wait_time = shrink_interval
		shrink_timer.one_shot = false
		shrink_timer.autostart = true
		shrink_timer.timeout.connect(_cleanup_unused)
		parent_node.add_child(shrink_timer)

	if spawn_loop_interval > 0.0:
		spawn_timer = Timer.new()
		spawn_timer.wait_time = spawn_loop_interval
		spawn_timer.one_shot = false
		spawn_timer.autostart = true
		spawn_timer.timeout.connect(_on_spawn_loop)
		parent_node.add_child(spawn_timer)

func _create_instance() -> Node:
	var inst = packed_scene.instantiate()
	inst.visible = false
	return inst

func _return_to_pool(inst: Node):
	if is_instance_valid(inst):
		inst.visible = false
		pool.append(inst)

func _process(_delta):
	#print("Temp: %s, Pool: %s" % [temp_pool.size(), pool.size()])
	if temp_pool.size() > 0:
		for inst in temp_pool:
			if is_instance_valid(inst):
				_return_to_pool(inst)
				temp_pool.erase(inst)

func get_instance() -> Node:
	var inst = _create_instance()
	active_instances.append(inst)
	parent_node.add_child(inst)
	inst.visible = true
	return inst
	
	"""if pool.is_empty():
		var inst = _create_instance()
		active_instances.append(inst)
		inst.visible = true
		return inst

	var inst = pool.pop_back()
	if is_instance_valid(inst):
		active_instances.append(inst)
		inst.visible = true
		return inst
	else:
		inst = _create_instance()
		active_instances.append(inst)
		inst.visible = true
		return inst"""

func release_instance(inst: Node):
	active_instances.erase(inst)
	inst.queue_free()
	
	"""if inst in active_instances:
		active_instances.erase(inst)
		var parent = inst.get_parent()
		parent.remove_child(inst)
	if is_instance_valid(inst):
		inst.visible = false
		temp_pool.append(inst)"""

func _cleanup_unused():
	while pool.size() > initial_size:
		var inst = pool.pop_back()
		if is_instance_valid(inst):
			inst.queue_free()

func _on_spawn_loop():
	var inst = get_instance()
