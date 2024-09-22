extends Node2D
class_name RespawnPoint

@export var spawn_point: SpawnPoint

@export var active_sprite: Sprite2D
@export var inactive_sprite: Sprite2D

@export var particles: GPUParticles2D

func set_active_sprite(is_active: bool) -> void:
	if is_active:
		active_sprite.show()
		inactive_sprite.hide()
		particles.show()
		particles.emitting = true
		particles.restart()
	else:
		active_sprite.hide()
		inactive_sprite.show()
		particles.emitting = false
		particles.hide()

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	if player.respawn_point == self:
		return
	set_active_sprite(true)
	if player.respawn_point != null:
		player.respawn_point.set_active_sprite(false)
	player.respawn_point = self
