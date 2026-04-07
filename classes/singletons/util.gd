extends Node

func soft_assert(condition: bool, message: String = "") -> bool:
	if not condition:
		print(message)
		return false
	
	return true
