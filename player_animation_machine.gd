extends Node2D
class_name PlayerAnimationMachine

enum SpecialState {
	NONE,
	DASH,
	LANDING_FROM_STOMP
}

var current_special_state: SpecialState = SpecialState.NONE
var state_timer: SceneTreeTimer

@onready var player: Player = self.get_parent()

@export var sprite: AnimatedSprite2D

# TODO: there is a better way to do this i just know there is
var time_sliding: float = 0.0
var time_falling: float = 0.0
var time_wall_sliding: float = 0.0
var time_crouching: float = 0.0

func set_animation_special_state(state: SpecialState, duration: float) -> void:
	current_special_state = state
	if state_timer != null and is_instance_valid(state_timer) and state_timer.time_left > 0:
		for dict in state_timer.timeout.get_connections():
			state_timer.timeout.disconnect(dict.callable)
	state_timer = get_tree().create_timer(duration)
	state_timer.timeout.connect(func () -> void:
		current_special_state = SpecialState.NONE
		)

func rl(anim_name: String) -> String:
	if player.last_look_direction.x > 0:
		return "R_" + anim_name
	else:
		return "L_" + anim_name

func rl_rev(anim_name: String) -> String:
	if player.last_look_direction.x > 0:
		return "L_" + anim_name
	else:
		return "R_" + anim_name

func update(delta: float) -> void:
	if player.dead:
		sprite.speed_scale = 1
		sprite.rotation = 0
		sprite.animation = rl("die")
		sprite.sprite_frames.set_animation_loop(rl("die"), false)
		return
	
	match current_special_state:
		SpecialState.NONE:
			sprite.rotation = 0
			pass
		SpecialState.DASH:
			sprite.speed_scale = 1
			sprite.look_at(sprite.global_position + Vector2(0, player.last_look_direction.y))
			sprite.animation = rl("dash")
			return
		SpecialState.LANDING_FROM_STOMP:
			sprite.speed_scale = 0
			sprite.animation = rl("land")
			sprite.frame = 0
			sprite.rotation = 0
			return
	
	if player.sliding_on_wall != Player.WallDirection.NONE and !player.is_on_floor():
		sprite.speed_scale = 1
		time_wall_sliding += delta
		time_wall_sliding = minf(time_wall_sliding, 0.2)
		time_crouching = 0
		if time_wall_sliding < 0.2:
			sprite.animation = rl_rev("wall_slide_start")
		else:
			sprite.animation = rl_rev("wall_slide_cont")
	elif player.crouch_state == Player.CrouchState.SLIDING:
		sprite.speed_scale = 1
		time_sliding += delta
		time_sliding = minf(time_sliding, 0.2)
		time_crouching = 0
		time_wall_sliding = 0
		if time_sliding < 0.2:
			sprite.animation = rl("slide_start")
		else:
			sprite.animation = rl("slide_cont")
	elif player.crouch_state != Player.CrouchState.SLIDING and time_sliding > 0.0:
		if abs(player.velocity.x) > 0.3 and time_sliding < 0.1:
			time_sliding = 0.0
			return
		time_sliding -= delta
		time_wall_sliding = 0
		time_crouching = 0
		sprite.speed_scale = 1
		sprite.animation = rl("slide_end")
	elif player.crouch_state == Player.CrouchState.CROUCHING:
		time_crouching += delta
		time_sliding = 0
		time_wall_sliding = 0
		if time_crouching < 0.3:
			sprite.animation = rl("crouch_start")
		else:
			sprite.speed_scale = abs(player.velocity.x / 100)
			sprite.animation = rl("crouch_cont")
	elif !player.is_on_floor():
		sprite.animation = rl("jump")
		sprite.speed_scale = 1
		time_wall_sliding = 0
		time_falling += delta
		time_crouching = 0
		if time_falling >= 0.6:
			sprite.speed_scale = 0
	elif player.is_on_floor() and abs(player.velocity.x) > 0.3:
		time_falling = 0.0
		time_wall_sliding = 0
		time_crouching = 0
		sprite.animation = rl("run")
		sprite.speed_scale = abs(player.velocity.x / 100)
	elif player.is_on_floor() and time_falling > 0.0:
		time_falling -= delta * 2
		time_wall_sliding = 0
		time_crouching = 0
		sprite.animation = rl("land")
		sprite.speed_scale = 1
	else:
		time_wall_sliding = 0
		time_crouching = 0
		sprite.animation = rl("idle")
		sprite.speed_scale = 1

func _process(delta: float) -> void:
	update(delta)
