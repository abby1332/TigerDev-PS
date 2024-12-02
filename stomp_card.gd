extends Card
class_name StompCard

var active: bool = false

func use(player: Player) -> void:
	sprite.queue_free()
	active = true
	player.is_stomping = true
	player.kill_everything_mode = true
	(player.get_node("StompParticles") as GPUParticles2D).emitting = true
	(player.get_node("StompParticles") as GPUParticles2D).show()

func _physics_process(_delta: float) -> void:
	if (active or Player.player.is_stomping) and Player.player.is_on_floor():
		# Delay resetting the states
		#await get_tree().create_timer(0.1).timeout
		active = false
		Player.player.kill_everything_mode = false
		Player.player.is_stomping = false
		(Player.player.get_node("StompParticles") as GPUParticles2D).emitting = false
		(Player.player.get_node("StompParticles") as GPUParticles2D).restart()
		(Player.player.get_node("StompParticles") as GPUParticles2D).hide()
		
		ExplosionManager.main.create_explosion(Player.player.get_node("StompPoint").global_position, false, 3)
		Player.player.animation_machine.current_special_state = PlayerAnimationMachine.SpecialState.LANDING_FROM_STOMP
		await FreezeFrameManager.zoom_frame(0.05, 0.5, 1.5, false)
		Player.player.animation_machine.current_special_state = PlayerAnimationMachine.SpecialState.NONE
		if Input.is_action_pressed("crouch"):
			Player.player.velocity.y = -100
		elif Input.is_action_pressed("up"):
			Player.player.velocity.y = -1000
		else:
			Player.player.velocity.y = -800
		
		queue_free()
