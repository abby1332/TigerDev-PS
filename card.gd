extends Node2D
class_name Card

func use(player: Player) -> void:
	push_error("Tried to use card from the base class, the use() function MUST be overriden!")
