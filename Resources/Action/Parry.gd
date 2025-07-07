extends ActionData
class_name ParryAction

func execute(actor, params = {}):
	var collided = actor.hurt.get_overlapping_bodies()
	var missiles: Array = []
	for obj in collided:
		if obj.base.tag == "projectile": if obj.stat.type == "Golden": missiles = obj
	
	for missile in missiles:
		missile.rotation_degrees = 180
		print("%s#%s parried a missile#%s!" % [actor.name, actor.base.id, missile.base.id])
