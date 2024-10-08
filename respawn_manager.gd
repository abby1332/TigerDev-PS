extends Node

var active_scene: Node
var player: Player

class SaveState:
	var player: Player
	var cards: Array[String]
	var used_card_spawners: Array[String] = []
	var active_respawn_point: String
	
	func _init(plyr: Player) -> void:
		player = plyr
		var card_manager := plyr.card_manager
		for card: Card in card_manager.cards:
			cards.append(card.scene_file_path)
		used_card_spawners.append_array(card_manager.used_card_spawners)
		
		active_respawn_point = plyr.respawn_point.name
	
	func load_save(plyr: Player, scene: Node) -> void:
		var card_manager := plyr.card_manager
		for path: String in cards:
			var card: Card = ResourceLoader.load(path).instantiate() as Card
			player.add_child(card)
			card_manager.give_card(card)
		card_manager.used_card_spawners.append_array(used_card_spawners)
		
		plyr.respawn_point = scene.find_child(active_respawn_point) as RespawnPoint
		plyr.respawn_point.spawn_point.teleport(plyr)
		plyr.respawn_point.inactive_sprite.hide()
		plyr.respawn_point.active_sprite.show()
	
	func _to_string() -> String:
		return " ".join(cards)

var current_save: SaveState

func save() -> void:
	current_save = SaveState.new(player)

func load_save() -> void:
	if current_save != null:
		current_save.load_save(player, active_scene)

func _ready() -> void:
	active_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	player = active_scene.find_child("Player") as Player

func respawn() -> void:
	load_scene(active_scene.scene_file_path)
	player = active_scene.find_child("Player") as Player
	load_save()

func load_scene(path: String) -> void:
	deferred_load_scene(path)

func deferred_load_scene(path: String) -> void:
	active_scene.queue_free()
	
	active_scene = ResourceLoader.load(path).instantiate()
	get_tree().root.add_child(active_scene)
	
