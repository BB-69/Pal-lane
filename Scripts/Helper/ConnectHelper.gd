extends Node

func c(dest1: Variant, sig: String, dest2: Variant, fn: String) -> Callable:
	if dest1 and dest2: if sig in dest1 and fn in dest2: if dest1 != null and dest2 != null:
		var callable = Callable(dest2, fn)
		if !dest1.is_connected(sig, callable):
			dest1.connect(sig, callable)
			return callable
	return Callable()
