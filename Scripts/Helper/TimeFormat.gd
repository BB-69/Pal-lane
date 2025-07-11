extends Node

"""
func t(current_time):
	var str: String = ""
	if current_time < 60.0:
		str = ("%.2f" % current_time) + "s"
	elif current_time < 3600.0:
		var total_min:int = int(current_time / 60.0)
		var min:String = ("%s" % total_min) + "m"
		var sec:String = ("%s" % int(current_time - total_min*60.0)) + "s"
		str = min + "" + sec
	else:
		var total_hour:int = int(current_time / 3600.0)
		var total_min:int = int(current_time - total_hour*60.0)
		var hour:String = ("%s" % total_hour) + "h"
		var min:String = ("%s" % total_min) + "m"
		var sec:String = ("%s" % int(current_time - total_min*60.0)) + "s"
		str = hour + "" + min + "" + sec
	return str
"""

func t(seconds: float) -> String:
	var result: Array = []
	var remaining: int = int(seconds)
	var started = false  # track if already started adding non-zero units
	
	var time_units = [
		{"label": "d", "value": 60*60*24},
		{"label": "h", "value": 60*60},
		{"label": "m", "value": 60},
		{"label": "s", "value": 1}
	]
	
	for unit in time_units:
		var amount = remaining / unit.value
		if (amount > 0 or started) and seconds >= 60:
			result.append("%d%s" % [amount, unit.label])
			started = true
		remaining %= unit.value
	
	if result.is_empty():
		return "%.2fs" % seconds
	else:
		return " ".join(result)
