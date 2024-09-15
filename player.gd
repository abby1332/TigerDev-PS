extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var jump_from_wall_directional_velocity = 350.0

@export var climbable_wall_layer = 2

@export var wall_slow_multiplier = 0.1
@export var leaving_wall_jump_grace_period = 0.15

# 0 = no wall, 1 = left wall, 2 = right wall
var sliding_on_wall = 0

var _wall_jumping = false
# 0 = no wall, 1 = left wall, 2 = right wall
var _wall_jumping_from = 0
var _leaving_wall = 0

# Checks which side of the player is sliding on a wall.
func sliding_on_wall_check(direction: float) -> int:
	var space = get_world_2d().direct_space_state
	var left_query = PhysicsRayQueryParameters2D.create(global_position, global_position - Vector2(5, 0), climbable_wall_layer)
	if len(space.intersect_ray(left_query)) != 0 and direction < 0:
		return 1
	var right_query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(5, 0), climbable_wall_layer)
	if len(space.intersect_ray(right_query)) != 0 and direction > 0:
		return 2
	if sliding_on_wall != 0:
		_leaving_wall = sliding_on_wall
		var leaving_wall_timer = Timer.new()
		add_child(leaving_wall_timer)
		leaving_wall_timer.wait_time = leaving_wall_jump_grace_period
		leaving_wall_timer.one_shot = true
		leaving_wall_timer.timeout.connect(_reset_leaving_wall)
		leaving_wall_timer.start()
	return 0

# Resets the player's wall jumping variables.
func _reset_wall_jumping() -> void:
	_wall_jumping = false
	_wall_jumping_from = 0
	
func _reset_leaving_wall() -> void:
	_leaving_wall = 0

func _physics_process(delta: float) -> void:
	
	# Get input movement direction.
	var direction := Input.get_axis("left", "right")
	
	sliding_on_wall = sliding_on_wall_check(direction)
	
	# Add the gravity.
	if not is_on_floor():
		if sliding_on_wall == 0:
			velocity += get_gravity() * delta
		else:
			if(velocity.y < 0):
				velocity.y *= 0.95
				velocity += get_gravity() * delta
			else:
				velocity += (get_gravity() * wall_slow_multiplier) * delta

	# Handle the movement/deceleration.
	if direction and not _wall_jumping:
		velocity.x = direction * speed
	elif _wall_jumping_from != 0:
		if _wall_jumping_from == 1:
			velocity.x = move_toward(velocity.x, jump_from_wall_directional_velocity, speed)
		else:
			velocity.x = move_toward(velocity.x, -jump_from_wall_directional_velocity, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and not _wall_jumping:
		if is_on_floor():
			velocity.y = jump_velocity
		# If we are sliding on a wall
		elif sliding_on_wall != 0 or _leaving_wall != 0:
			if ((direction < 0 and sliding_on_wall == 1) or _leaving_wall == 1) or ((direction > 0 and sliding_on_wall == 2) or _leaving_wall == 2):
				_wall_jumping = true
				velocity.y = jump_velocity * 0.75
				if sliding_on_wall != 0:
					_wall_jumping_from = sliding_on_wall
				else:
					_wall_jumping_from = _leaving_wall
				var reset_wall_jumping_timer = Timer.new()
				add_child(reset_wall_jumping_timer)
				reset_wall_jumping_timer.wait_time = 0.25
				reset_wall_jumping_timer.one_shot = true
				reset_wall_jumping_timer.timeout.connect(_reset_wall_jumping)
				reset_wall_jumping_timer.start()
			

	move_and_slide()
