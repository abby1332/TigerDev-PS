extends Node2D
# TODO: Change global hair node position based on current animation? Or even follow certain animations
@onready var sprite_count = 8.0
@onready var grav_scale = 8.0 # Higher it is the lower gravity is :p
@onready var distance = 0.1
@onready var radius = 2.5
var animation_offset := Vector2.ZERO
var points = []

func _ready() -> void:
	# max_dist, (pos_x, pos_y), radius
	for i in range(sprite_count):
		points.append([distance - i * (distance / sprite_count), Vector2(0, 0), radius - i * (radius / sprite_count)])
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = !(owner.dead)
	for j in range(sprite_count):
		for i in range(len(points)-1, -1, -1):
			if i == 0:
				points[i][1] = global_position
				continue
			
			if points[i][1].distance_to(points[i-1][1]) > points[i][2]:
				var dir = (points[i-1][1].direction_to(points[i][1]))
				var offset = dir * points[i][2]

				points[i][1] = offset + points[i-1][1]
			points[i][1] += ((owner.get_gravity() / (grav_scale * 20)) * delta)
			queue_redraw()
		
	
func _draw():
	pass
	for point in points:
		draw_circle(point[1] - global_position, point[2], Color(0.6745, 0.196, 0.196, 1.0))
