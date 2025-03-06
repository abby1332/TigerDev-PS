extends CanvasLayer

# Plays a dissolve screen animation before respawn
func respawn_scene() -> void:
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	RespawnManager.respawn()
	$AnimationPlayer.play_backwards('dissolve')

#Plays a dissolve screen animation before changing scenes
func change_scene(target: String) -> void:
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	get_tree().change_scene(target)
	$AnimationPlayer.play_backwards('dissolve')
