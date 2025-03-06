extends Node2D
class_name Card
## A card object.
##
## Should be overridden by every card

@export var sprite: Sprite2D


# Override this in implementing classes
func use(_player: Player) -> void:
	push_error("Tried to use card from the base class, the use() function MUST be overriden!")


func _ready() -> void:
	# If we don't know the sprite, make an attempt to find it in the children
	if sprite == null:
		for n in get_children():
			if n is Sprite2D:
				sprite = n as Sprite2D
				break

	# If the parent isn't a dropped card at spawn then it shouldn't be visible to the player
	if not get_parent() is DroppedCard:
		hide()
