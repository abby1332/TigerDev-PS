extends Area2D
class_name Explosion

@onready var particles: GPUParticles2D = $Particles
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var collider: CollisionShape2D = $CollisionShape2D

var hurts_player: bool = true
var size: float = 1.0

signal finished


func start() -> void:
	sound.pitch_scale += randf_range(-0.4, 0)
	sound.play()
	scale = Vector2(size, size)
	particles.emitting = true
	explosion_go_away(0.1)
	await particles.finished
	finished.emit()


func explosion_go_away(duration: float) -> void:
	await get_tree().create_timer(duration * Engine.time_scale).timeout
	collider.disabled = true


func _on_body_entered(body: Node2D) -> void:
	if body is Player and hurts_player:
		(body as Player).die()
	elif body is BasicEnemy:
		(body as BasicEnemy).die()
