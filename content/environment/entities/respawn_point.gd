extends Node2D
class_name RespawnPoint
## Respawn Point for the player to respawn at.

## The abstract spawn point position for the player
@export var spawn_point: SpawnPoint

## Sprite that will be displayed when the respawn point has been touched
@export var active_sprite: Sprite2D
## Sprite that will be displayed when the respawn point hasn't been touched
@export var inactive_sprite: Sprite2D

## Special effects!!! :DDDDD
@export var particles: GPUParticles2D

## Changes the active sprite
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

## When the player touches the respawn point activate it
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
	RespawnManager.save()
