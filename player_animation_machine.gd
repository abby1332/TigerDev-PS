extends Node2D
class_name PlayerAnimationMachine

@onready var player: Player = self.get_parent()

@export var sprite: AnimatedSprite2D

func rl(anim_name: String) -> String:
	if(player.last_look_direction.x > 0):
		return "r_" + anim_name
	else:
		return "l_" + anim_name

func update() -> void:
	pass

func _process(delta: float) -> void:
	pass
