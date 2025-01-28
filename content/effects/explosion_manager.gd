extends Node2D
class_name ExplosionManager

static var main: ExplosionManager

@export var explosion_scene: PackedScene


func _ready() -> void:
	main = self


func create_explosion(location: Vector2, hurts_player: bool = true, size: float = 1.0) -> void:
	var explosion := explosion_scene.instantiate() as Explosion
	add_child(explosion)
	explosion.global_position = location
	explosion.hurts_player = hurts_player
	explosion.size = size
	explosion.start()
	await explosion.finished
	explosion.queue_free()
