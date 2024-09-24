extends Camera2D
class_name MainCamera

@export var target: Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(get_viewport().size.y * zoom.y)
	
	var target_pos := target.global_position
	
	
	global_position = target.global_position
