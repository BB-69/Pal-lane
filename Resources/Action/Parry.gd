extends ActionData
class_name ParryAction

signal parry(actor)
signal slash(actor)
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
	
	Con.c(self, "slash", Stat.Ptc.ptcc, "_on_slash")
	emit_signal("slash", actor)
	disconnect("slash", Callable(Stat.Ptc.ptcc, "_on_slash"))
	if Stat.Aud: Stat.Aud.audc._on_sound(actor, "slash")
