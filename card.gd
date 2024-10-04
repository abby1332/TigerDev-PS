extends Node2D
class_name Card

@export var sprite: Sprite2D

func use(_player: Player) -> void:
	push_error("Tried to use card from the base class, the use() function MUST be overriden!")

func _ready() -> void:
	if sprite == null:
		for n in get_children():
			if n is Sprite2D:
				sprite = n as Sprite2D
				break
	
	if not get_parent() is DroppedCard:
		hide()
