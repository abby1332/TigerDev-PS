extends Node2D
class_name PlayerAnimationMachine

@onready var player: Player = self.get_parent()

@export var sprite: AnimatedSprite2D

var time_sliding: float = 0.0
var time_falling: float = 0.0

func rl(anim_name: String) -> String:
	if player.last_look_direction.x > 0:
		return "R_" + anim_name
	else:
		return "L_" + anim_name

func update(delta: float) -> void:
	if player.crouch_state == Player.CrouchState.SLIDING:
		sprite.speed_scale = 1
		time_sliding += delta
		time_sliding = minf(time_sliding, 0.2)
		if time_sliding < 0.2:
			sprite.animation = rl("slide_start")
		else:
			sprite.animation = rl("slide_cont")
	elif player.crouch_state != Player.CrouchState.SLIDING and time_sliding > 0.0:
		if abs(player.velocity.x) > 0.3 and time_sliding < 0.1:
			time_sliding = 0.0
			return
		time_sliding -= delta
		sprite.speed_scale = 1
		sprite.animation = rl("slide_end")
	elif !player.is_on_floor():
		sprite.animation = rl("jump")
		sprite.speed_scale = 1
		time_falling += delta
		if time_falling >= 0.6:
			sprite.speed_scale = 0
	elif player.is_on_floor() and abs(player.velocity.x) > 0.3:
		time_falling = 0.0
		sprite.animation = rl("run")
		sprite.speed_scale = abs(player.velocity.x / 100)
	elif player.is_on_floor() and time_falling > 0.0:
		time_falling -= delta * 2
		sprite.animation = rl("land")
		sprite.speed_scale = 1
	else:
		sprite.animation = rl("idle")
		sprite.speed_scale = 1

func _process(delta: float) -> void:
	update(delta)
