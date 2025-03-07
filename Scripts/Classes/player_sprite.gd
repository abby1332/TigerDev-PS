class_name PlayerSprite
extends AnimatedSprite2D

#region Hair Node System

class HairNode:
	extends  Sprite2D

	const IMAGE: CompressedTexture2D = preload("res://Assets/Images/Player/hair.png");
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

@onready var _hair_node_a: HairNode = HairNode.new(Vector2(0.0, -13.0));
@onready var _hair_node_b: HairNode = HairNode.new(Vector2(0.0, -7.0));
@onready var _hair_node_c: HairNode = HairNode.new(Vector2(0.0, -1.0));
@onready var _hair_node_d: HairNode = HairNode.new(Vector2(0.0, 5.0));

var head_position: Vector2 = Vector2.ZERO;

#endregion

#region Constants

const RIGHT_FRAMES: SpriteFrames = preload("res://Resources/SpriteFrames/Player/right_frames.tres");
const LEFT_FRAMES: SpriteFrames = preload("res://Resources/SpriteFrames/Player/left_frames.tres");

# These are purely for code aesthetic.
const RIGHT: bool = true;
const LEFT: bool = false;

# This is used to scale the animation speed with the running speed.
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
const SLIDING: StringName = &"sliding";
