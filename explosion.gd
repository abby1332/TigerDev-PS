extends Area2D
class_name Explosion

@onready var particles: GPUParticles2D = $Particles
@onready var sound: AudioStreamPlayer2D = $Sound

var hurts_player: bool = true
var size: float = 1.0

signal finished

func start() -> void:
	sound.pitch_scale += randf_range(-0.4, 0)
	sound.play()
	scale = Vector2(size, size)
	particles.emitting = true
	for body in get_overlapping_bodies():
		if body is Player and hurts_player:
			(body as Player).die()
		elif body is BasicEnemy:
			(body as BasicEnemy).die()
	await particles.finished
	finished.emit()
