class_name PlayerNode
extends CharacterBody2D

#region Typing

## Player's Curent Movestate
enum MoveState {
	# Standing On Ground
	Grounded,
	# Holding Wall
	Grasping,
	# In Air | No Jump / Launch Used
	Falling,
	# In Air | Jumped
	Jumping,
	# In Air | Launched From Wall
	Launching,
	# Activating Card
	Carding,
}

#endregion

#region Sub Nodes

# This is used to get the mouse position.
@onready var viewport: Viewport = get_viewport();

# Children Nodes
@export_category("Child Nodes")
@export var sprite: PlayerSprite;
@export var camera: Camera2D;
@export var collider: CollisionShape2D;
@export var head_raycast: RayCast2D;
@export var leg_raycast: RayCast2D;

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

## Stores jump input as a time buffer.
var has_jump_input: float = 0.0;

## Stores card cycle inputs between physics frames.
var has_cycle_input: float = 0.0;

#endregion

#region Private Funcs

func _process(dt: float) -> void:
	# Movement Input
	movement_input += Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down") * dt;

	# Fresh Movement Input
	if Input.is_action_just_pressed(&"move_up"):
		has_jump_input = Mechanics.PLAYER_JUMP_BUFFER;
		fresh_movement_input.y = -1.0;
	elif Input.is_action_just_pressed(&"move_down"):
		fresh_movement_input.y = 1.0;
	if Input.is_action_just_pressed(&"move_right"):
		fresh_movement_input.x = 1.0;
	elif Input.is_action_just_pressed(&"move_left"):
		fresh_movement_input.x = -1.0;

	# Card Input
	if Input.is_action_just_pressed(&"use_card"):
		has_card_input = Mechanics.PLAYER_CARD_BUFFER;
	if Input.is_action_just_pressed(&"cycle_card_next"):
		has_cycle_input += dt;
	if Input.is_action_just_pressed(&"cycle_card_prev"):
		has_cycle_input -= dt;

	# Debug Tools
	if Input.is_action_just_pressed(&"debug_freeze"):
		breakpoint

	#if Input.is_action_just_pressed(&"debug_give_card"):
		#the_cards.add_card(1);

func _physics_process(dt: float) -> void:
	var a: Level = Level.new();
	
	process_move_state();

	apply_motion(dt);

	move_and_slide();

	update_post_process(dt);

#endregion

#region Movement Methods

## Processes & Manages Current MoveState
func process_move_state() -> void:
	match move_state:
		MoveState.Grounded:
			if _can_set_move_state_carding():
				_set_move_state_carding();
			elif _can_set_move_state_jumping():
				_set_move_state_jumping();
			elif _can_set_move_state_falling():
				_set_move_state_falling();

		MoveState.Jumping:
			if _can_set_move_state_carding():
				_set_move_state_carding();
			elif _can_set_move_state_grounded():
				_set_move_state_grounded();
			elif _can_set_move_state_grasping():
				_set_move_state_grasping();

		MoveState.Falling:
			if _can_set_move_state_carding():
				_set_move_state_carding();
			elif _can_set_move_state_jumping():
				_set_move_state_jumping();
			elif _can_set_move_state_launching():
				_set_move_state_launching();
			elif _can_set_move_state_grounded():
				_set_move_state_grounded();
			elif _can_set_move_state_grasping():
				_set_move_state_grasping();

		MoveState.Grasping:
			if _can_set_move_state_carding():
				_set_move_state_carding();
			elif _can_set_move_state_launching():
				_set_move_state_launching();
			elif _can_set_move_state_grounded():
				_set_move_state_grounded();
			elif _can_set_move_state_falling():
				_set_move_state_falling();

		MoveState.Launching:
			if _can_set_move_state_carding():
				_set_move_state_carding();
			elif _can_set_move_state_grasping():
				_set_move_state_grasping();
			elif _can_set_move_state_falling():
				_set_move_state_falling();
			elif _can_set_move_state_grounded():
				_set_move_state_grounded();

		MoveState.Carding:
			# TODO - Card Stuff
			pass

		_:
			pass

## Applies Motion To The Player
func apply_motion(dt: float) -> void:
	match move_state:
		MoveState.Grounded: _apply_motion_grounded(dt);
		MoveState.Jumping: _apply_motion_jumping(dt);
		MoveState.Falling: _apply_motion_falling(dt);
		MoveState.Grasping: _apply_motion_grasping(dt);
		MoveState.Launching: _apply_motion_launching(dt);
		MoveState.Carding: _apply_motion_carding(dt);
		_: pass

#endregion

#region Util Methods

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

## Sets `HeadRay` And `LegRay`Target Positions Based On Movement Input
func update_rays() -> void:
	head_raycast.target_position.x = signf(movement_input.x) * Mechanics.PLAYER_SIDE_RAY_LENGTH;
	leg_raycast.target_position.x = signf(movement_input.x) * Mechanics.PLAYER_SIDE_RAY_LENGTH;

## Updates Sprite Based On Movement State
func update_sprite(dt: float) -> void:
	match move_state:
		MoveState.Grounded:
			sprite.update_animation_grounded(velocity.x, is_on_wall());

		MoveState.Jumping, MoveState.Falling, MoveState.Launching:
			sprite.update_current_direction(velocity.x);

		MoveState.Grasping, MoveState.Carding:
			pass

		_:
			pass

	sprite.update_hair(velocity * dt);

## Returns The Relative Position Of The Cursor As A Normalized Vector
func get_cursor_position() -> Vector2:
	# NOTE - This function gets the position of the cursor relative to the center of the screen.
	# NOTE - If the player isn't in the center of the screen, then this function needs to be changed to account for that.
	var mp: Vector2 = viewport.get_mouse_position();

	mp -= Vector2(Mechanics.SCREEN_WIDTH / 2.0, Mechanics.SCREEN_HEIGHT / 2.0);

	return mp.normalized();

#endregion

#region MoveState Methods

# Grounded

func _can_set_move_state_grounded() -> bool:
	match move_state:
		MoveState.Grounded, MoveState.Grasping:
			return false;

		MoveState.Jumping, MoveState.Falling:
			return is_on_floor();

		MoveState.Launching:
			return is_on_floor() && hang_time > Mechanics.PLAYER_LAUNCH_STATE_DURATION;

		MoveState.Carding:
			# TODO - Figure out how to handle card states.
			return false;

		_:
			return false;

func _set_move_state_grounded() -> void:
	# Update Animation
	match move_state:
		MoveState.Grounded: return
		MoveState.Grasping, MoveState.Launching: pass
		MoveState.Jumping, MoveState.Falling: sprite.play_landing();
		MoveState.Carding: sprite.play_recoiling();
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
	if movement_input.x == 0: # Passive Deceleration
		velocity.x = move_toward(
			velocity.x, 0,
			Mechanics.PLAYER_HORIZONTAL_ACCELERATION * Mechanics.PLAYER_DECELERATION_RATIO * dt
		);
	elif ( # Decelerating While Over Max Speed
		signf(velocity.x) == signf(movement_input.x) &&
		absf(velocity.x) > Mechanics.PLAYER_TOP_HORIZONTAL_SPEED
	):
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

	# Vertical | Constant Gentle Downward Velocity
	velocity.y = Mechanics.PLAYER_GRAVITY * dt;

# Grasping

func _can_set_move_state_grasping() -> bool:
	match move_state:
		MoveState.Grounded, MoveState.Grasping:
			return false;

		MoveState.Jumping:
			return (
				head_raycast.is_colliding() && leg_raycast.is_colliding() &&
				is_on_wall_only() && signf(get_wall_normal().x) == -signf(movement_input.x) &&
				# NOTE - This lets the player hold up so that they don't grasp the wall until they start falling.
				 !(movement_input.y < 0.0 && velocity.y < 0.0)
			);

		MoveState.Launching:
			return (
				hang_time > Mechanics.PLAYER_LAUNCH_STATE_DURATION &&
				head_raycast.is_colliding() && leg_raycast.is_colliding() &&
				is_on_wall_only() && signf(get_wall_normal().x) == -signf(movement_input.x) &&
				# NOTE - This lets the player hold up so that they don't grasp the wall until they start falling.
				!(movement_input.y < 0.0 && velocity.y < 0.0)
			);

		MoveState.Falling:
			return (
				can_grasp &&
				head_raycast.is_colliding() && leg_raycast.is_colliding() &&
				is_on_wall_only() && signf(get_wall_normal().x) == -signf(movement_input.x)
			);

		MoveState.Carding:
			# TODO - Figure out card system.
			return false;

		_:
			return false;

func _set_move_state_grasping() -> void:
	if move_state == MoveState.Grasping: return;

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

# Falling

func _can_set_move_state_falling() -> bool:
	match self.move_state:
		MoveState.Grounded:
			return !is_on_floor();

		MoveState.Jumping, MoveState.Falling:
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

		MoveState.Carding:
			# TODO - Figure out card stuff.
			return false;

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
	elif ( # Decelerating While Over Max Speed
		signf(velocity.x) == signf(movement_input.x) &&
		absf(velocity.x) > Mechanics.PLAYER_TOP_HORIZONTAL_SPEED
	):
		# NOTE - This prevents the player from decelerating faster while pressing a movement key than while not pressing any key.
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

# Jumping

func _can_set_move_state_jumping() -> bool:
	match move_state:
		MoveState.Grounded:
			return has_jump_input > 0.0;

		MoveState.Jumping, MoveState.Grasping, MoveState.Launching:
			return false;

		MoveState.Falling:
			# NOTE This doesn't check `can_launch.`
			# NOTE `can_jump` is set to false when you grasp a wall, so this shouldn't cause issues.
			return (
				can_jump &&
				has_jump_input > 0.0 &&
				hang_time <= Mechanics.PLAYER_GROUNDED_BUFFER
			);

		MoveState.Carding:
			# TODO - Figure out card stuff.
			return false;

		_:
			return false;

func _set_move_state_jumping() -> void:
	if move_state == MoveState.Jumping: return;

	move_state = MoveState.Jumping;
	move_direction = Vector2(0.0, -1.0);
	hang_time = 0.0;

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
		# NOTE - This prevents the player from decelerating faster while pressing a movement key than while not pressing any key.
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

# Launching

func _can_set_move_state_launching() -> bool:
	match move_state:
		MoveState.Grounded, MoveState.Jumping, MoveState.Launching:
			return false;

		MoveState.Grasping:
			return has_jump_input > 0.0;

		MoveState.Falling:
			return (
				can_launch && has_jump_input > 0.0 &&
				hang_time <= Mechanics.PLAYER_LAUNCHING_BUFFER
			);

		MoveState.Carding:
			# TODO - Figure out card stuff.
			return false;

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

# Carding (TODO)

func _can_set_move_state_carding() -> bool:
	return false;

func _set_move_state_carding() -> void:
	pass

func _apply_motion_carding(_dt: float) -> void:
	pass

#endregion
