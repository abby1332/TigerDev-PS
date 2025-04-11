class_name PlayerSprite2D
extends AnimatedSprite2D

class HairNode:
	extends  Sprite2D

	const IMAGE: CompressedTexture2D = preload("res://resources/sprites/hair.png");
	const SEPARATION_DISTANCE: float = 4.0;
	const GRAVITY_INFLUENCE: float = 0.9;
	const VELOCITY_DECAY: float = 0.5;

	var tension: Vector2 = Vector2.ZERO;
	var velocity: Vector2 = Vector2.ZERO;

	func _init(pos: Vector2) -> void:
		texture = IMAGE;
		position = pos;
		visibility_layer = 4;
		visible = true;
		z_index = -1;

	func add_movement(movement: Vector2) -> void:
		position += velocity - movement;

	func get_tension(left_node: HairNode, right_node: HairNode) -> void:
		var my_pos: Vector2 = position - left_node.position;
		var ten_vec: Vector2 = right_node.position - left_node.position;

		if my_pos == Vector2.ZERO: my_pos = Vector2(0.0, 0.01);
		if ten_vec == Vector2.ZERO: ten_vec = Vector2(0.0, 0.01);

		tension = my_pos.project(ten_vec) / SEPARATION_DISTANCE;
		if tension == Vector2.ZERO: tension.y = -0.1;

	func apply_tension_around(node: HairNode) -> void:
		var dir: Vector2 = (Vector2(0.0, GRAVITY_INFLUENCE) + tension).limit_length();
		velocity = (velocity + dir * VELOCITY_DECAY).limit_length();
		position = node.position + dir * SEPARATION_DISTANCE;

#region Constants

const RIGHT_FRAMES: SpriteFrames = preload("res://content/player/right.tres");
const LEFT_FRAMES: SpriteFrames = preload("res://content/player/left.tres");

# These are purely for code aesthetic.
const RIGHT: bool = true;
const LEFT: bool = false;

## This is used to scale the animation speed with the running speed.
const RUN_ANIMATION_SPEED_RATIO: float = 0.8 / 128.0;

# Animation Names
const DYING: StringName = &"dying";
const DASHING: StringName = &"dashing";
const GRASPING: StringName = &"grasping";
const IDLE: StringName = &"idle";
const JUMPING: StringName = &"jumping";
const LANDING: StringName = &"landing";
const RECOILING: StringName = &"recoiling";
const RUNNING: StringName = &"running";
const SLASHING: StringName = &"slashing";

#endregion

#region Variables

var current_direction: bool = RIGHT;
var current_animation: StringName = JUMPING;
var head_position: Vector2 = Vector2.ZERO;

@onready var hair_node_a: HairNode = HairNode.new(Vector2(0.0, -13.0));
@onready var hair_node_b: HairNode = HairNode.new(Vector2(0.0, -7.0));
@onready var hair_node_c: HairNode = HairNode.new(Vector2(0.0, -1.0));
@onready var hair_node_d: HairNode = HairNode.new(Vector2(0.0, 5.0));

#endregion

#region Private Functions

func _ready() -> void:
	sprite_frames = RIGHT_FRAMES;
	play(current_animation);
	add_child(hair_node_a);
	add_child(hair_node_b);
	add_child(hair_node_c);
	add_child(hair_node_d);

# Switches SpriteFrames Based On `current_direction`
func _update_frames() -> void:
	var current_frame: int = frame;
	var current_progress: float = frame_progress;

	if current_direction == RIGHT:
		if sprite_frames != RIGHT_FRAMES:
			sprite_frames = RIGHT_FRAMES;
	else:
		if sprite_frames != LEFT_FRAMES:
			sprite_frames = LEFT_FRAMES;

	if current_animation != RUNNING:
		speed_scale = 1.0;

	play(current_animation);
	set_frame_and_progress(current_frame, current_progress);

# Returns the position of the player's head based on their current animation.
func _get_head_position() -> Vector2:
	match current_animation:
		IDLE:
			match frame:
				0, 4: return Vector2(-2.0 if current_direction else 2.0, -12.0);
				1, 3: return Vector2(-2.0 if current_direction else 2.0, -11.0);
				2: return Vector2(-2.0 if current_direction else 2.0, -10.0);
				5: return Vector2(-2.0 if current_direction else 2.0, -13.0);
				_: return Vector2.ZERO;
		DYING:
			return Vector2(-4.0, -14.0) if current_direction else Vector2(4.0, -14.0);
		DASHING:
			return Vector2(4.0, -12.0) if current_direction else Vector2(-4.0, -12.0);
		GRASPING:
			match frame:
				0: return Vector2(2.0 if current_direction else -2.0, -14.0);
				1: return Vector2(2.0 if current_direction else -2.0, -12.0);
				2: return Vector2(2.0 if current_direction else -2.0, -9.0);
				_: return Vector2.ZERO;
		JUMPING:
			return Vector2(-2.0 if current_direction else 2.0, -14.0);
		LANDING:
			match frame:
				0: return Vector2(-2.0 if current_direction else 2.0, -5.0);
				1: return Vector2(-2.0 if current_direction else 2.0, -8.0);
				2: return Vector2(-2.0 if current_direction else 2.0, -10.0);
				3: return Vector2(-2.0 if current_direction else 2.0, -11.0);
				4: return Vector2(-2.0 if current_direction else 2.0, -13.0);
				_: return Vector2.ZERO;
		RECOILING:
			match frame:
				0: return Vector2(-6.0 if current_direction else 6.0, -11.0);
				1: return Vector2(-3.0 if current_direction else 3.0, -12.0);
				2: return Vector2(-1.0 if current_direction else 1.0, -13.0);
				3: return Vector2(0.0, -13.0);
				_: return Vector2.ZERO;
		RUNNING:
			match frame:
				0, 3, 7: return Vector2(0.0, -13.0);
				1, 2, 5, 6: return Vector2(0.0, -11.0);
				4: return Vector2(0.0, -14.0);
				_: return Vector2.ZERO;
		SLASHING:
			return Vector2(2.0, -11.0) if current_direction else Vector2(-2.0, -11.0);
		_:
			return Vector2.ZERO;

#endregion

#region Public Functions

## Updates The Player's Hair
func update_hair(movement: Vector2) -> void:
	hair_node_a.position = _get_head_position();
	hair_node_b.add_movement(movement);
	hair_node_c.add_movement(movement);
	hair_node_d.add_movement(movement);

	hair_node_b.get_tension(hair_node_a, hair_node_c);
	hair_node_b.apply_tension_around(hair_node_a);
	hair_node_c.get_tension(hair_node_b, hair_node_d);
	hair_node_c.apply_tension_around(hair_node_b);
	hair_node_d.get_tension(hair_node_a, hair_node_d);
	hair_node_d.apply_tension_around(hair_node_c);

## Changes `current_direction` Based On Given Input
func update_current_direction(x_velocity: float) -> void:
	if current_direction == RIGHT:
		if x_velocity < 0.0:
			current_direction = LEFT;
			_update_frames();
	else:
		if x_velocity > 0.0:
			current_direction = RIGHT;
			_update_frames();

## Updates Player Animation While On Ground
func update_grounded_animation(x_velocity: float, is_on_wall: bool) -> void:
	if current_direction == RIGHT:
		if x_velocity < 0.0: current_direction = LEFT;
	else:
		if x_velocity > 0.0: current_direction = RIGHT;

	if !is_on_wall && x_velocity != 0.0:
		# NOTE - speed_scale gets reset in _update_frames when the animation to something else.
		speed_scale = absf(x_velocity) * RUN_ANIMATION_SPEED_RATIO;

		if current_animation != RUNNING:
			current_animation = RUNNING;
	elif current_animation != IDLE:
		if !(
				(current_animation == LANDING && frame < 4) ||
				(current_animation == RECOILING && frame < 3)
		):
			current_animation = IDLE;

	_update_frames();

func play_dying() -> void:
	current_animation = DYING;
	speed_scale = 1.0;
	play(current_animation);

func play_dashing() -> void:
	current_animation = DASHING;
	speed_scale = 1.0;
	play(current_animation);

func play_grasping() -> void:
	current_animation = GRASPING;
	speed_scale = 1.0;
	play(current_animation);

func play_idle() -> void:
	current_animation = IDLE;
	speed_scale = 1.0;
	play(current_animation);

func play_jumping() -> void:
	current_animation = JUMPING;
	speed_scale = 1.0;
	play(current_animation);

func play_landing() -> void:
	current_animation = LANDING;
	speed_scale = 1.0;
	play(current_animation);

func play_recoiling() -> void:
	current_animation = RECOILING;
	speed_scale = 1.0;
	play(current_animation);

func play_running() -> void:
	current_animation = RUNNING;
	speed_scale = 1.0;
	play(current_animation);

func play_slashing() -> void:
	current_animation = SLASHING;
	speed_scale = 1.0;
	play(current_animation);

func play_launching() -> void:
	# Part Of Jump Animation
	current_animation = JUMPING;
	play(current_animation);
	speed_scale = 1.0;
	set_frame_and_progress(2, 0.0);

func play_falling() -> void:
	# Part Of Jump Animation
	current_animation = JUMPING;
	play(current_animation);
	speed_scale = 1.0;
	set_frame_and_progress(4, 0.0);

#endregion
