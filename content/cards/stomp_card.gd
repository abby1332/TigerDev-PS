extends Card
class_name StompCard
## Explosive Stomp Card
##
## Player falls down quick then gets launched up

## Is the card active
var active: bool = false


## Uses the card. I'm so tired.
func use(player: Player) -> void:
	sprite.queue_free()
	active = true
	player.is_stomping = true
	player.kill_everything_mode = true
	(player.get_node("StompParticles") as GPUParticles2D).emitting = true
	(player.get_node("StompParticles") as GPUParticles2D).show()


func _physics_process(_delta: float) -> void:
	# If the card is still active and the player is on the floor
	if (active) and Player.player.is_on_floor():
		active = false
		# Deactivates the "kill everything mode"
		Player.player.kill_everything_mode = false
		Player.player.is_stomping = false
		(Player.player.get_node("StompParticles") as GPUParticles2D).emitting = false
		(Player.player.get_node("StompParticles") as GPUParticles2D).restart()
		(Player.player.get_node("StompParticles") as GPUParticles2D).hide()

		ExplosionManager.main.create_explosion(
			Player.player.get_node("StompPoint").global_position, false, 3
		)
		Player.player.animation_machine.current_special_state = (
			PlayerAnimationMachine.SpecialState.LANDING_FROM_STOMP
		)
		await FreezeFrameManager.zoom_frame(0.05, 0.5, 1.5, false)
		Player.player.animation_machine.current_special_state = (
			PlayerAnimationMachine.SpecialState.NONE
		)
		if Input.is_action_pressed("crouch"):
			Player.player.velocity.y = -100
		elif Input.is_action_pressed("up"):
			Player.player.velocity.y = -1000
		else:
			Player.player.velocity.y = -800

		queue_free()
