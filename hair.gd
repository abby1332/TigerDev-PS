extends Node2D
# TODO: Change global hair node position based on current animation? Or even follow certain animations
@onready var sprite_count = 4.0
@onready var grav_scale = 3.0 # Higher it is the lower gravity is :p
@onready var distance = 0.1
@onready var radius = 2.5
var animation_offset := Vector2.ZERO
var points = []

func _ready() -> void:
	# max_dist, (pos_x, pos_y), radius
	for i in range(sprite_count):
		points.append([1, Vector2(0, 0), 2])
	animation_offset = Vector2(1.2, -10) # If the player starting direction ever changes, change the x value here to negative

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = !(owner.dead)
	# Animation offset (evil)
	var animation_machine = owner.animation_machine

	var direction = owner.last_look_direction
	var running = animation_machine.sprite.animation == animation_machine.rl("run")
	var left = false
	var slide = false
	
	if (direction.x < 0.0):
		left = true
	elif (direction.x > 0.0):
		left = false
	
	if running and not left: # Weird offset here due to animation not being centered im like 80% sure
		animation_offset.x = -0.6
	else:
		animation_offset.x = 1.2
		
	if (animation_machine.sprite.animation == animation_machine.rl("dash")): # Evil and unnatural
		var frame = animation_machine.sprite.frame
		if left:
			match frame:
				0:
					animation_offset.x = -2.0
				1:
					animation_offset.x = -1.5
					animation_offset.y = -9.5
				2:
					animation_offset.x = -1.5
					animation_offset.y = -9.5
				3:
					animation_offset.x = -1.5
					animation_offset.y = -9.5
				4:
					animation_offset.x = -1.5
					animation_offset.y = -9.5
				5:
					animation_offset.x = -1.5
					animation_offset.y = -9.5
				6:
					animation_offset.x = 0.5
					animation_offset.y = -9.0
				7:
					animation_offset.x = 0.5
					animation_offset.y = -9.5
				8:
					animation_offset.x = 1.2
					animation_offset.y = -10.0
				9:
					animation_offset.x = 1.2
					animation_offset.y = -10.0
		else:
			match frame:
				0:
					animation_offset.x = 2.0
				1:
					animation_offset.x = 1.5
					animation_offset.y = -9.5
				2:
					animation_offset.x = 1.5
					animation_offset.y = -9.5
				3:
					animation_offset.x = 1.5
					animation_offset.y = -9.5
				4:
					animation_offset.x = 1.5
					animation_offset.y = -9.5
				5:
					animation_offset.x = 1.5
					animation_offset.y = -9.5
				6:
					animation_offset.x = -0.5
					animation_offset.y = -9.0
				7:
					animation_offset.x = -0.5
					animation_offset.y = -9.5
				8:
					animation_offset.x = -1.2
					animation_offset.y = -10.0
				9:
					animation_offset.x = -1.2
					animation_offset.y = -10.0
		
	elif (animation_machine.sprite.animation == animation_machine.rl("slide_start")):
		var frame = animation_machine.sprite.frame
		slide = true
		if left:
			match frame:
				0:
					animation_offset.y = -5.0
					animation_offset.x = 4.5
				1:
					animation_offset.y = -4.5
					animation_offset.x = 5.0
		else:
			match frame:
				0:
					animation_offset.y = -5.0
					animation_offset.x = -4.0
				1:
					animation_offset.y = -4.5
					animation_offset.y = -5.0
		
	elif (animation_machine.sprite.animation == animation_machine.rl("slide_cont")):
		var frame = animation_machine.sprite.frame
		slide = true
		if left:
			animation_offset.x = 5.0
			match frame:
				0:
					animation_offset.y = -4.0
				1:
					animation_offset.y = -4.5
				2:
					animation_offset.y = -4.0
				3:
					animation_offset.y = -4.5
		else:
			animation_offset.x = -5.0
			match frame:
				0:
					animation_offset.y = -4.0
				1:
					animation_offset.y = -4.5
				2:
					animation_offset.y = -4.0
				3:
					animation_offset.y = -4.5
		
	elif (animation_machine.sprite.animation == animation_machine.rl("slide_end")):
		var frame = animation_machine.sprite.frame
		slide = true
		if left:
			match frame:
				0:
					animation_offset.y = -4.5
					animation_offset.x = 4.0
				1:
					animation_offset.y = -6.5
					animation_offset.x = 2.5
				2:
					animation_offset.y = -8.0
					animation_offset.x = 1.2
		else:
			match frame:
				0:
					animation_offset.y = -4.5
					animation_offset.x = -4.0
				1:
					animation_offset.y = -6.5
					animation_offset.x = -2.5
				2:
					animation_offset.y = -8.0
					animation_offset.x = -1.2
		
		
	elif (direction.x < 0.0):
		animation_offset.x = abs(animation_offset.x)
	elif (direction.x > 0.0):
		animation_offset.x = abs(animation_offset.x) * -1.0
		
	if (animation_machine.sprite.animation == animation_machine.rl("idle")): # Hair follows head bob here
		var frame = animation_machine.sprite.frame
		match frame:
			0:
				animation_offset.y = -10
			1:
				animation_offset.y = -9.5
			2:
				animation_offset.y = -9
			3:
				animation_offset.y = -9.5
			4:
				animation_offset.y = -10
			5:
				animation_offset.y = -10.5
	elif (animation_machine.sprite.animation == animation_machine.rl("land")): # This is awful
		var frame = animation_machine.sprite.frame
		match frame:
			0:
				animation_offset.y = -6
			1:
				animation_offset.y = -7
			2:
				animation_offset.y = -7.5
			3:
				animation_offset.y = -8
			4:
				animation_offset.y = -8.5
			5:
				animation_offset.y = -8.5
			6:
				animation_offset.y = -9
			7:
				animation_offset.y = -9.5
			8:
				animation_offset.y = -10
	elif not slide:
		animation_offset.y = -10
		
	
	# Proper hair code
	for j in range(sprite_count):
		for i in range(len(points)-1, -1, -1):
			if i == 0:
				points[i][1] = global_position + animation_offset
				continue
			
			if points[i][1].distance_to(points[i-1][1]) > points[i][2]:
				var dir = (points[i-1][1].direction_to(points[i][1]))
				var offset = dir * points[i][2]

				points[i][1] = offset + points[i-1][1]
			points[i][1] += ((owner.get_gravity() / (grav_scale * 20)) * delta)
			queue_redraw()
		
	
func _draw():
	for point in points: # replace with actual proper sprites later?
		draw_circle(point[1] - global_position, point[2], Color(0.6745, 0.196, 0.196, 1.0))
