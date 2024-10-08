extends Node

var active_scene: Node
var player: Player

class SaveState:
	var player: Player
	var cards: Array[String]
	var used_card_spawners: Array[String]
	
	func _init(plyr: Player) -> void:
		player = plyr
		var card_manager := plyr.card_manager
		for card: Card in card_manager.cards:
			cards.append(card.scene_file_path)
		used_card_spawners = card_manager.used_card_spawners
	
	func load_save(plyr: Player) -> void:
		var card_manager := plyr.card_manager
		for path: String in cards:
			var card: Card = ResourceLoader.load(path).instantiate() as Card
			player.add_child(card)
			card_manager.give_card(card)
		card_manager.used_card_spawners = used_card_spawners
	
	func _to_string() -> String:
		return " ".join(cards)

var current_save: SaveState

func save() -> void:
	current_save = SaveState.new(player)

func load_save() -> void:
	current_save.load_save(player)

func _ready() -> void:
	active_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	player = active_scene.find_child("Player") as Player

func respawn(respawn_location: Vector2) -> void:
	load_scene(active_scene.scene_file_path)
	player = active_scene.find_child("Player") as Player
	player.global_position = respawn_location
	
	load_save()

func load_scene(path: String) -> void:
	deferred_load_scene(path)

func deferred_load_scene(path: String) -> void:
	active_scene.queue_free()
	
	active_scene = ResourceLoader.load(path).instantiate()
	get_tree().root.add_child(active_scene)
	
