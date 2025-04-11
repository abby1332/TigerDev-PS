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
}

#endregion

#region Exports

@export_category("Level Dependant Items")
@export var spawn_point: SpawnPoint;

@export_category("Player Scene Items")
@export var card_manager: CameraManager;
@export var player_sprite: PlayerSprite2D;
