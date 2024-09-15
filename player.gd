extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var jump_from_wall_directional_velocity = 1200.0

@export var climbable_wall_layer = 2

# 0 = no wall, 1 = left wall, 2 = right wall
var sliding_on_wall = 0

var _wall_jumping = false
# 0 = no wall, 1 = left wall, 2 = right wall
var _wall_jumping_from = 0

# Checks which side of the player is sliding on a wall.
func sliding_on_wall_check() -> int:
	var space = get_world_2d().direct_space_state
	var left_query = PhysicsRayQueryParameters2D.create(global_position, global_position - Vector2(5, 0), climbable_wall_layer)
	if len(space.intersect_ray(left_query)) != 0:
		return 1
	var right_query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(5, 0), climbable_wall_layer)
	if len(space.intersect_ray(right_query)) != 0:
		return 2
	return 0

# Resets the player's wall jumping variables.
func _reset_wall_jumping() -> void:
	_wall_jumping = false
	_wall_jumping_from = 0

func _physics_process(delta: float) -> void:
	
	sliding_on_wall = sliding_on_wall_check()
	
	# Add the gravity.
	if not is_on_floor():
		if sliding_on_wall == 0:
			velocity += get_gravity() * delta
		else:
			if(velocity.y < 0):
				velocity.y /= 2
			velocity += (get_gravity() / 3) * delta

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction and not _wall_jumping:
		velocity.x = direction * speed
	elif _wall_jumping_from != 0:
		if _wall_jumping_from == 1:
			velocity.x = move_toward(velocity.x, 250, speed)
		else:
			velocity.x = move_toward(velocity.x, -250, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and not _wall_jumping:
		if is_on_floor():
			velocity.y = jump_velocity
		# If we are sliding on a wall
		elif sliding_on_wall != 0:
			_wall_jumping = true
			velocity.y = jump_velocity * 1.5
			_wall_jumping_from = sliding_on_wall
			var reset_wall_jumping_timer = Timer.new()
			add_child(reset_wall_jumping_timer)
			reset_wall_jumping_timer.wait_time = 0.35
			reset_wall_jumping_timer.one_shot = true
			reset_wall_jumping_timer.timeout.connect(_reset_wall_jumping)
			reset_wall_jumping_timer.start()
			

	move_and_slide()
