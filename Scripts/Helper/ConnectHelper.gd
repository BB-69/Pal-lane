extends Node

func c(dest1: Variant, sig: String, dest2: Variant, fn: String):
	if dest1 and dest2:
		if !dest1.has_connections(sig): dest1.connect(sig, Callable(dest2, fn))
