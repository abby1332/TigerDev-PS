extends CharacterBody2D

#region Typing

enum MoveState {
	Grounded, # On Ground; Free To Move
	Jumping, # Jumping; In Air
	Falling, # Falling; In Air But Didn't Jump (e.g. Walked Off Of Platform)
	Grasping, # Holding Wall
	Launching, # Jumped From Wall
	Slashing, # Slash Card
	Stomping, # Stomp Card
	Dead,
}

signal player_died;
signal load_checkpoint;
signal update_checkpoint;

#endregion

#region Exports & Onreadys

@export_category("Level Dependant Items")
@export var spawn_point: SpawnPoint;

@export_category("Player Scene Items")
@export var cards: CardManager = null;
@export var sprite: PlayerSprite2D;
@export var camera: Camera2D;
@export var head_raycast: RayCast2D;
@export var leg_raycast: RayCast2D;

@onready var viewport: Viewport = get_viewport();

#endregion

#region Movement Vars

## Defines the current state of and restricions on the player's movements.
var move_state: MoveState = MoveState.Falling;

## Stores the relevant direction & magnitude of a move state.
var move_direction: Vector2 = Vector2.ZERO;

## Time spent in current movement state. (s)
var hang_time: float = 0.0;

## True when player can jump.
var can_jump: bool = false;

## True when player can grasp a wall.
var can_grasp: bool = false;

## True when player can launch from a wall.
var can_launch: bool = false;

#endregion

#region Input Vars

## Stores directional input between physics frames.
var movement_input: Vector2 = Vector2.ZERO;

## Stores most recent directional input.
## Currently only used for wall launch.
var fresh_movement_input: Vector2 = Vector2.ONE;

## Stores card action input as a time buffer.
var has_card_input: float = 0.0;

## Index of most recent card to be activated.
var last_active_card: int = 0;

## Stores jump input as a time buffer.
var has_jump_input: float = 0.0;

## Stores card cycle inputs between physics frames.
var has_cycle_input: float = 0.0;

#endregion

#region Node Funcs

func _ready() -> void:
	position = spawn_point.position;

func _physics_process(dt: float) -> void:
	if move_state == MoveState.Dead: return;

	check_input(dt);

	process_move_state();

	apply_motion(dt);

	move_and_slide();

	update_post_process(dt);

#endregion

#region Movement Methods

## Processes & Manages Current MoveState
func process_move_state() -> void:
	match move_state:
		MoveState.Dead: return;

		MoveState.Grounded:
			if _can_set_move_state_dead():
				_set_move_state_dead();
			elif _can_set_move_state_slashing():
				_set_move_state_slashing();
			elif _can_set_move_state_jumping():
				_set_move_state_jumping();
			elif _can_set_move_state_falling():
				_set_move_state_falling();

		MoveState.Jumping:
			if _can_set_move_state_dead():
				_set_move_state_dead();
			elif _can_set_move_state_slashing():
				_set_move_state_slashing();
			elif _can_set_move_state_grounded():
				_set_move_state_grounded();
			elif _can_set_move_state_grasping():
				_set_move_state_grasping();

		MoveState.Falling:
			if _can_set_move_state_dead():
				_set_move_state_dead();
			elif _can_set_move_state_slashing():
				_set_move_state_slashing();
			elif _can_set_move_state_jumping():
				_set_move_state_jumping();
			elif _can_set_move_state_launching():
				_set_move_state_launching();
			elif _can_set_move_state_grounded():
				_set_move_state_grounded();
			elif _can_set_move_state_grasping():
				_set_move_state_grasping();

		MoveState.Grasping:
			if _can_set_move_state_dead():
				_set_move_state_dead();
			elif _can_set_move_state_slashing():
				_set_move_state_slashing();
			elif _can_set_move_state_launching():
				_set_move_state_launching();
			elif _can_set_move_state_grounded():
				_set_move_state_grounded();
			elif _can_set_move_state_falling():
				_set_move_state_falling();

		MoveState.Launching:
			if _can_set_move_state_dead():
				_set_move_state_dead();
			elif _can_set_move_state_slashing():
				_set_move_state_slashing();
			elif _can_set_move_state_grasping():
				_set_move_state_grasping();
			elif _can_set_move_state_falling():
				_set_move_state_falling();
			elif _can_set_move_state_grounded():
				_set_move_state_grounded();

		MoveState.Slashing:
			if _can_set_move_state_dead():
				_set_move_state_dead();
			elif _can_set_move_state_grounded():
				_set_move_state_grounded();
			elif _can_set_move_state_grasping():
				_set_move_state_grasping();
			elif _can_set_move_state_falling():
				_set_move_state_falling();

		# TODO - Add Stomp State
		_: pass

## Applies Motion To The Player
func apply_motion(dt: float) -> void:
	match move_state:
		MoveState.Dead: return;
		MoveState.Grounded: _apply_motion_grounded(dt);
		MoveState.Jumping: _apply_motion_jumping(dt);
		MoveState.Falling: _apply_motion_falling(dt);
		MoveState.Grasping: _apply_motion_grasping(dt);
		MoveState.Launching: _apply_motion_launching(dt);
		MoveState.Slashing: _apply_motion_slashing(dt);
		# TODO - Add Stomp State
		_: pass

#endregion

#region  Util Methods

func check_input(dt: float) -> void:
	# Movement Input
	movement_input = Input.get_vector(&"left", &"right", &"up", &"crouch") * dt;

	# Fresh Movement Input
	if Input.is_action_just_pressed(&"up"):
		has_jump_input = Mechanics.PLAYER_JUMP_BUFFER;
		fresh_movement_input.y = -1.0;
	elif Input.is_action_just_pressed(&"crouch"):
		fresh_movement_input.y = 1.0;
	if Input.is_action_just_pressed(&"right"):
		fresh_movement_input.x = 1.0;
	elif Input.is_action_just_pressed(&"left"):
		fresh_movement_input.x = -1.0;

	# Takes card input when there isn't any buffered input.
	if last_active_card == 0:
		if Input.is_action_just_pressed(&"card_1"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card = 1;
		elif Input.is_action_just_pressed(&"card_2"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card = 2;
		elif Input.is_action_just_pressed(&"card_3"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card = 3;
		elif Input.is_action_just_pressed(&"card_4"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card = 4;
		elif Input.is_action_just_pressed(&"card_5"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card = 5;

	# Cycle Card Input
	if Input.is_action_just_pressed(&"send_top_card_to_back"):
		has_cycle_input += dt;
		if last_active_card != 0:
			last_active_card = 5 if last_active_card == 1 else last_active_card - 1;
	if Input.is_action_just_pressed(&"send_back_card_to_top"):
		has_cycle_input -= dt;
		if last_active_card != 0:
				last_active_card = 1 if last_active_card == 5 else last_active_card + 1;

	if Input.is_action_just_pressed(&"debug_freeze"):
		breakpoint

	if Input.is_action_just_pressed(&"debug_die"):
		_set_move_state_dead();

## Cleans Up After `_physics_process()` Is Done
func update_post_process(dt: float) -> void:
	# Call These Before Clearing Inputs
	update_sprite(dt);
	update_rays();

	# Reset Stored Input
	movement_input = Vector2(0.0, 0.0);
	has_cycle_input = 0.0;

	# Update Timers & Buffers
	hang_time += dt;
	if has_jump_input > 0.0: has_jump_input -= dt;
	if has_card_input > 0.0: has_card_input -= dt;
	elif last_active_card != 0: last_active_card = 0;

## Sets `HeadRay` And `LegRay`Target Positions Based On Movement Input
func update_rays() -> void:
	head_raycast.target_position.x = signf(movement_input.x) * Mechanics.PLAYER_SIDE_RAY_LENGTH;
	leg_raycast.target_position.x = signf(movement_input.x) * Mechanics.PLAYER_SIDE_RAY_LENGTH;

## Updates Sprite Based On Movement State
func update_sprite(dt: float) -> void:
	match move_state:
		MoveState.Grounded:
			sprite.update_grounded_animation(velocity.x, is_on_wall());

		MoveState.Jumping, MoveState.Falling, MoveState.Launching:
			sprite.update_current_direction(velocity.x);

		MoveState.Grasping, MoveState.Slashing:
			pass

		_:
			pass

	sprite.update_hair(velocity * dt);

## Returns The Relative Direction Of The Cursor
func get_cursor_position() -> Vector2:
	# TODO - This needs to be updated to account for camera drift.
	var mp: Vector2 = viewport.get_mouse_position();

	mp -= Vector2(Mechanics.VIEWPORT_WIDTH / 2.0, Mechanics.VIEWPORT_HEIGHT / 2.0);
	# This adjusts for the camera drag.
	mp += camera.get_screen_center_position() - camera.get_target_position();

	return mp.normalized();

#endregion

#region MoveState Methods

# Dead

func _can_set_move_state_dead() -> bool:
	match move_state:
		MoveState.Dead: return false;

		MoveState.Grounded, MoveState.Jumping, MoveState.Falling, \
		MoveState.Grasping, MoveState.Launching:
			for index in get_slide_collision_count():
				pass

		MoveState.Slashing, MoveState.Stomping:
			for body: PhysicsBody2D in get_last_slide_collision():
				# If dashing into environmental hazard
				if body.get_collision_layer_value(3) && body.get_collision_layer_value(4):
					return true;

		_: pass

	return false;

func _set_move_state_dead() -> void:
	player_died.emit();

	velocity = Vector2.ZERO;
	move_state = MoveState.Dead;
	move_direction = Vector2.ZERO;
	hang_time = 0.0;
	sprite.play_dying();

	await get_tree().create_timer(Mechanics.PLAYER_RESPAWN_TIME).timeout;

	position = spawn_point.position;
	_set_move_state_falling();

	load_checkpoint.emit();

# Grounded

func _can_set_move_state_grounded() -> bool:
	match move_state:
		MoveState.Grounded, MoveState.Grasping, MoveState.Stomping:
			return false;

		MoveState.Jumping, MoveState.Falling:
			return is_on_floor();

		MoveState.Launching:
			return is_on_floor() && hang_time > Mechanics.PLAYER_LAUNCH_STATE_DURATION;

		MoveState.Slashing:
			return is_on_floor() && (hang_time > Mechanics.PLAYER_SLASH_STATE_DURATION || velocity == Vector2.ZERO);

		_:
			return false;

func _set_move_state_grounded() -> void:
	match move_state:
		MoveState.Grounded: return
		MoveState.Grasping, MoveState.Stomping: pass
		MoveState.Jumping, MoveState.Falling: sprite.play_landing();
		MoveState.Slashing: sprite.play_recoiling();
		_: pass

	move_state = MoveState.Grounded;
	move_direction = Vector2.ZERO;
	hang_time = 0.0;

	velocity.x = clampf(velocity.x, -Mechanics.PLAYER_TERMINAL_VELOCITY.x, Mechanics.PLAYER_TERMINAL_VELOCITY.x);

	can_jump = true;
	can_grasp = true;
	can_launch = false;

func _apply_motion_grounded(dt: float) -> void:
	# Horizontal
	# Horizontal
	if movement_input.x == 0: # Passive Deceleration
		velocity.x = move_toward(
			velocity.x, 0,
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * Mechanics.PLAYER_DECELERATION_RATIO * dt
		);
	elif (
		signf(velocity.x) == signf(movement_input.x) &&
		absf(velocity.x) > Mechanics.PLAYER_TOP_HORIZONTAL_SPEED
	): # Decelerating While Over Max Speed
		# NOTE - This prevents the player from decelerating faster while pressing a movement key than if they just let go.
		velocity.x = move_toward(
			velocity.x, Mechanics.PLAYER_TOP_HORIZONTAL_SPEED * signf(movement_input.x),
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * Mechanics.PLAYER_DECELERATION_RATIO * dt
		);
	else: # Regular Acceleration & Deceleration
		velocity.x = move_toward(
			velocity.x, Mechanics.PLAYER_TOP_HORIZONTAL_SPEED * signf(movement_input.x),
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * dt
		);

	# Vertical | Constant Gentle Downward Force
	velocity.y = Mechanics.PLAYER_GRAVITY * dt;

# Jumping

func _can_set_move_state_jumping() -> bool:
	match move_state:
		MoveState.Grounded:
			return has_jump_input > 0.0;

		MoveState.Jumping, MoveState.Grasping,\
		MoveState.Launching, MoveState.Slashing:
			return false;

		MoveState.Falling:
			# NOTE This doesn't check `can_launch.`
			# NOTE `can_jump` is set to false when you grasp a wall, so this shouldn't cause issues.
			return (
				can_jump &&
				has_jump_input > 0.0 &&
				hang_time <= Mechanics.PLAYER_GROUNDED_BUFFER
			);

		MoveState.Stomping:
			return is_on_floor();

		_: return false;

func _set_move_state_jumping() -> void:
	if move_state == MoveState.Jumping: return;

	move_state = MoveState.Jumping;
	hang_time = 0.0;

	if move_state == MoveState.Stomping:
		move_direction = get_floor_normal();
		velocity = move_direction * Mechanics.PLAYER_STOMP_SPEED;
	else:
		move_direction = Vector2(0.0, -1.0);
		velocity.y = Mechanics.PLAYER_JUMP_FORCE;

	has_jump_input = 0.0;
	can_jump = false;
	can_grasp = true;
	can_launch = false;

	sprite.play_jumping();

func _apply_motion_jumping(dt: float) -> void:
	# Horizontal
	if movement_input.x == 0: # Passive Deceleration
		velocity.x = move_toward(
			velocity.x, 0,
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * Mechanics.PLAYER_DECELERATION_RATIO * Mechanics.PLAYER_AIR_STRAFE_MULTIPLIER * dt
		);
	elif (
		signf(velocity.x) == signf(movement_input.x) &&
		absf(velocity.x) > Mechanics.PLAYER_TOP_HORIZONTAL_SPEED
	): # Decelerating While Over Max Speed
		# NOTE - This prevents the player from decelerating faster while pressing a movement key than if they just let go.
		velocity.x = move_toward(
			velocity.x, Mechanics.PLAYER_TOP_HORIZONTAL_SPEED * signf(movement_input.x),
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * Mechanics.PLAYER_DECELERATION_RATIO * Mechanics.PLAYER_AIR_STRAFE_MULTIPLIER * dt
		);
	else: # Regular Acceleration & Deceleration
		velocity.x = move_toward(
			velocity.x, Mechanics.PLAYER_TOP_HORIZONTAL_SPEED * signf(movement_input.x),
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * Mechanics.PLAYER_AIR_STRAFE_MULTIPLIER * dt
		);

	# Vertical
	if is_on_ceiling():
		velocity.y = Mechanics.PLAYER_GRAVITY * dt;
	else:
		if hang_time < Mechanics.PLAYER_JUMP_HOLD_DURATION && movement_input.y < 0.0:
			velocity.y = move_toward(
				velocity.y,
				Mechanics.PLAYER_TERMINAL_VELOCITY.y,
				Mechanics.PLAYER_GRAVITY * Mechanics.PLAYER_JUMP_FLOAT_RATIO * dt
			);
		else:
			velocity.y = move_toward(
				velocity.y,
				Mechanics.PLAYER_TERMINAL_VELOCITY.y,
				Mechanics.PLAYER_GRAVITY * dt
			);

	# Terminal Velocity
	velocity.x = clampf(velocity.x, -Mechanics.PLAYER_TERMINAL_VELOCITY.x, Mechanics.PLAYER_TERMINAL_VELOCITY.x);
	velocity.y = clampf(velocity.y, -Mechanics.PLAYER_TERMINAL_VELOCITY.y, Mechanics.PLAYER_TERMINAL_VELOCITY.y);

# Falling

func _can_set_move_state_falling() -> bool:
	match self.move_state:
		MoveState.Grounded:
			return !is_on_floor();

		MoveState.Jumping, MoveState.Falling, MoveState.Stomping:
			return false;

		MoveState.Grasping:
			return (
				(move_direction.x != signf(movement_input.x) &&
				move_direction.x != fresh_movement_input.x) ||
				!(head_raycast.is_colliding() && leg_raycast.is_colliding()) ||
				hang_time > Mechanics.PLAYER_WALL_SLIDE_DURATION
			);

		MoveState.Launching:
			return (
				hang_time > Mechanics.PLAYER_LAUNCH_STATE_DURATION ||
				velocity == Vector2.ZERO
			);

		MoveState.Slashing:
			return (
				hang_time > Mechanics.PLAYER_SLASH_STATE_DURATION ||
				velocity == Vector2.ZERO
			);

		_:
			return false;

func _set_move_state_falling() -> void:
	if move_state == MoveState.Falling: return;

	move_state = MoveState.Falling;
	hang_time = 0.0;

	sprite.play_falling();

func _apply_motion_falling(dt: float) -> void:
	# Horizontal
	if movement_input.x == 0: # Passive Deceleration
		velocity.x = move_toward(
			velocity.x, 0,
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * Mechanics.PLAYER_DECELERATION_RATIO * Mechanics.PLAYER_AIR_STRAFE_MULTIPLIER * dt
		);
	elif (
		signf(velocity.x) == signf(movement_input.x) &&
		absf(velocity.x) > Mechanics.PLAYER_TOP_HORIZONTAL_SPEED
	): # Decelerating While Over Max Speed
		# NOTE - This prevents the player from decelerating faster while pressing a movement key than if they just let go.
		velocity.x = move_toward(
			velocity.x, Mechanics.PLAYER_TOP_HORIZONTAL_SPEED * signf(movement_input.x),
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * Mechanics.PLAYER_DECELERATION_RATIO * Mechanics.PLAYER_AIR_STRAFE_MULTIPLIER * dt
		);
	else: # Regular Acceleration & Deceleration
		velocity.x = move_toward(
			velocity.x, Mechanics.PLAYER_TOP_HORIZONTAL_SPEED * signf(movement_input.x),
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * Mechanics.PLAYER_AIR_STRAFE_MULTIPLIER * dt
		);

	# Vertical
	if is_on_ceiling():
		velocity.y = Mechanics.PLAYER_GRAVITY * dt;
	else:
		velocity.y = move_toward(
			velocity.y,
			Mechanics.PLAYER_TERMINAL_VELOCITY.y,
			Mechanics.PLAYER_GRAVITY * dt
		);

	# Terminal Velocity
	velocity.x = clampf(velocity.x, -Mechanics.PLAYER_TERMINAL_VELOCITY.x, Mechanics.PLAYER_TERMINAL_VELOCITY.x);
	velocity.y = clampf(velocity.y, -Mechanics.PLAYER_TERMINAL_VELOCITY.y, Mechanics.PLAYER_TERMINAL_VELOCITY.y);

# Grasping

func _can_set_move_state_grasping() -> bool:
	match move_state:
		MoveState.Grounded, MoveState.Grasping, MoveState.Stomping:
			return false;

		MoveState.Jumping:
			return (
				head_raycast.is_colliding() && leg_raycast.is_colliding() &&
				is_on_wall_only() && signf(get_wall_normal().x) == -signf(movement_input.x) &&
				# NOTE - This lets the player hold up so that they don't grasp the wall when jumping against it.
				 !(movement_input.y < 0.0 && velocity.y < 0.0)
			);

		MoveState.Launching:
			return (
				hang_time > Mechanics.PLAYER_LAUNCH_STATE_DURATION &&
				head_raycast.is_colliding() && leg_raycast.is_colliding() &&
				is_on_wall_only() && signf(get_wall_normal().x) == -signf(movement_input.x) &&
				# NOTE - This lets the player hold up so that they don't grasp the wall when jumping against it.
				!(movement_input.y < 0.0 && velocity.y < 0.0)
			);

		MoveState.Slashing:
			return (
				hang_time > Mechanics.PLAYER_SLASH_STATE_DURATION &&
				head_raycast.is_colliding() && leg_raycast.is_colliding() &&
				is_on_wall_only() && signf(get_wall_normal().x) == -signf(movement_input.x)
			);

		MoveState.Falling:
			return (
				can_grasp &&
				head_raycast.is_colliding() && leg_raycast.is_colliding() &&
				is_on_wall_only() && signf(get_wall_normal().x) == -signf(movement_input.x)
			);

		_:
			return false;

func _set_move_state_grasping() -> void:
	move_state = MoveState.Grasping;
	move_direction = -get_wall_normal();
	hang_time = 0.0;

	velocity.y = 0.0;

	can_jump = false;
	can_grasp = false;
	can_launch = true;

	sprite.play_grasping();

func _apply_motion_grasping(dt: float) -> void:
	# Horizontal | Slight Nudge Into Wall
	velocity.x = move_direction.x * Mechanics.PLAYER_TOP_HORIZONTAL_SPEED * dt;

	# Vertical | Slide After Initial Frozen Period
	if hang_time > Mechanics.PLAYER_WALL_GRASP_DURATION:
		velocity.y = Mechanics.PLAYER_WALL_SLIDE_SPEED;

# Launching

func _can_set_move_state_launching() -> bool:
	match move_state:
		MoveState.Grounded, MoveState.Jumping,\
		MoveState.Launching, MoveState.Slashing, \
		MoveState.Stomping:
			return false;

		MoveState.Grasping:
			return has_jump_input > 0.0;

		MoveState.Falling:
			return (
				can_launch && has_jump_input > 0.0 &&
				hang_time <= Mechanics.PLAYER_LAUNCHING_BUFFER
			);

		_:
			return false;

func _set_move_state_launching() -> void:
	if move_state == MoveState.Launching: return;

	move_state = MoveState.Launching;
	move_direction = Vector2(-signf(move_direction.x), 0.0);
	hang_time = 0.0;

	velocity = Mechanics.PLAYER_LAUNCH_FORCE;
	velocity.x *= move_direction.x;

	has_jump_input = 0.0;
	can_grasp = true;
	can_launch = false;

	sprite.play_launching();
	sprite.update_current_direction(move_direction.x);

func _apply_motion_launching(dt: float) -> void:
	# Horizontal | None
	# Vertical
	if is_on_ceiling():
		velocity.y = Mechanics.PLAYER_GRAVITY * dt;
	else:
		velocity.y = move_toward(
			velocity.y,
			Mechanics.PLAYER_TERMINAL_VELOCITY.y,
			Mechanics.PLAYER_GRAVITY * dt
		);

	# NOTE - Nothing should make the player move faster horizontally while launching, so this only caps y velocity.
	velocity.y = clampf(velocity.y, -Mechanics.PLAYER_TERMINAL_VELOCITY.y, Mechanics.PLAYER_TERMINAL_VELOCITY.y);

# Slashing

func _can_set_move_state_slashing() -> bool:
	match move_state:
		MoveState.Slashing, MoveState.Stomping:
			return false;

		MoveState.Jumping, MoveState.Falling, MoveState.Launching:
			# TODO - Make the card system actually work.
			return last_active_card != 0;

		MoveState.Grounded:
			return (
				# TODO - Make the card system actually work.
				last_active_card != 0 &&
				# This prevents the player from slashing into the floor at a low angle.
				get_floor_normal().dot(get_cursor_position()) > Mechanics.PLAYER_SLASH_SLIDE_THRESHOLD
			);

		MoveState.Grasping:
			return (
				# TODO - Make the card system actually work.
				last_active_card != 0 &&
				# This prevents dashing into the wall they're grasping,
				signf(get_cursor_position().x) != signf(move_direction.x)
			);

		_:
			return false;

func _set_move_state_slashing() -> void:
	if move_state == MoveState.Slashing: return;

	move_state = MoveState.Slashing;
	move_direction = get_cursor_position();
	hang_time = 0.0;

	if velocity.dot(move_direction) < 0:
		velocity = move_direction * Mechanics.PLAYER_SLASH_SPEED;
	else:
		velocity = velocity.project(move_direction) + move_direction * Mechanics.PLAYER_SLASH_SPEED;

	# NOTE - This is a mild missuse of the `move_directon` variable.
	# NOTE - It was intended to just be for direction, but this uses it for magnitude.
	move_direction = velocity;

	has_jump_input = 0.0;
	has_card_input = 0.0;
	can_jump = false;
	can_grasp = true;
	can_launch = false;

	# TODO - Actually use a slash card.
	sprite.play_slashing();
	sprite.update_current_direction(move_direction.x);

func _apply_motion_slashing(_dt: float) -> void:
	# Logic Summary

	# if touching two surfaces:
		# set velocity to zero

	# if touching a single surface:
		# if moving into wall:
			# set velocity to zero
		# else:
			# slide over the surface

	# if not touching anything:
		# keep on cruising

	# NOTE - This function mildly missuses move_direction.
	# NOTE - The slash's velocity is stored as the magnitdue of move_direction.
	# NOTE - Make sure to normalize move_direction when handling dot products.

	if is_on_floor():
		if is_on_wall():
			# Touching Two Surfaces
			velocity = Vector2.ZERO;
		else:
			var normal: Vector2 = get_floor_normal();
			var dot: float = normal.dot(move_direction.normalized());

			if dot < 0.0:
				if dot < Mechanics.PLAYER_SLASH_SLIDE_THRESHOLD:
					# Slashing Into Surface
					velocity = Vector2.ZERO;
				else:
					# Sliding Over Surface
					velocity.x = -normal.y * move_direction.x;
					velocity.y = -absf(normal.x * move_direction.x);
			else:
				# Moving Along/Away From Surface
				velocity = move_direction;

	elif is_on_ceiling():
		if is_on_wall():
			# Touching Two Surfaces
			velocity = Vector2.ZERO;
		else:
			var normal: Vector2 = get_last_slide_collision().get_normal();
			var dot: float = normal.dot(move_direction.normalized());

			if dot < 0.0:
				if dot < Mechanics.PLAYER_SLASH_SLIDE_THRESHOLD:
					# Slashing Into Surface
					velocity = Vector2.ZERO;
				else:
					# Sliding Over Surface
					velocity.x = normal.y * move_direction.x;
					velocity.y = absf(normal.x * move_direction.x);
			else:
				# Moving Along/Away From Surface
				velocity = move_direction;

	elif is_on_wall():
		var normal: Vector2 = get_last_slide_collision().get_normal();
		var dot: float = normal.dot(move_direction.normalized());

		if dot < 0.0:
			if dot < Mechanics.PLAYER_SLASH_SLIDE_THRESHOLD:
				# Slashing Into Surface
				velocity = Vector2.ZERO;
			else:
				# Sliding Over Surface
				velocity.x = absf(normal.y) * move_direction.x;
				velocity.y = absf(normal.x) * move_direction.y;
		else:
			# Moving Along/Away From Surface
			velocity = move_direction;
	else:
		# Not Touching Stuff
		velocity = move_direction;

# TODO - Add stomp state stuff

#endregion
