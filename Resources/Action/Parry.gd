extends ActionData
class_name ParryAction

signal parry(actor)

func execute(actor, params = {}):
	var collided = actor.hurt.get_overlapping_bodies()
	var missiles: Array[ProjectileClass] = []
	for body in collided:
		if body.base.tag == "Projectile": if body.stat.type == "Golden": missiles.append(body)
	
	var callables: Array[Callable]
	for missile in missiles:
		callables.append(Con.c(self, "parry", missile, "_on_parry"))
	emit_signal("parry", actor)
	for c in callables:
		disconnect("parry", c)
