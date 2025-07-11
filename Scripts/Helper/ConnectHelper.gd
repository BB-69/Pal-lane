extends Node

func c(dest1: Variant, sig: String, dest2: Variant, fn: String) -> Callable:
	if dest1 and dest2:
		var callable = Callable(dest2, fn)
		if !dest1.is_connected(sig, callable):
			dest1.connect(sig, callable)
			return callable
	return Callable()
