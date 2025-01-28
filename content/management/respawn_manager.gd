extends Node
## Makes respawn mechanics work

## The current level/scene/whatever
var active_scene: Node
## The current player instance
var player: Player

## Saves select data currently in the session
class SaveState:
	var player: Player
	var cards: Array[String]
	var used_card_spawners: Array[String] = []
	var active_respawn_point: String

	## Creates a save with all of the current data
	func _init(plyr: Player) -> void:
		player = plyr
		var card_manager := player.card_manager
		for card: Card in card_manager.cards:
			cards.append(card.scene_file_path)
		used_card_spawners.append_array(card_manager.used_card_spawners)

		active_respawn_point = player.respawn_point.name

	## Sets all data currently to that of this save state
	func load_save(plyr: Player, scene: Node) -> void:
		var card_manager := plyr.card_manager
		for path: String in cards:
			var card: Card = ResourceLoader.load(path).instantiate() as Card
			plyr.add_child(card)
			card_manager.give_card(card)
		card_manager.used_card_spawners.append_array(used_card_spawners)

		plyr.respawn_point = scene.find_child(active_respawn_point) as RespawnPoint
		plyr.respawn_point.spawn_point.teleport(plyr)
		plyr.respawn_point.inactive_sprite.hide()
		plyr.respawn_point.active_sprite.show()

	func _to_string() -> String:
		return " ".join(cards)

## The current save
var current_save: SaveState

var _welcome_back_message_template: String = """[pulse freq=3.0 color=#00FFF  ease=-1][color=FF0000][outline_size=5][font_size=100][center][font=res://resources/fonts/monogram-extended.ttf]{text}[/font][/center][/font_size][/outline_size][/color][/pulse]"""
var _welcome_back_messages: Array[String] = [
	"DEATH CANNOT STOP YOU",
	"TRY HARDER THIS TIME",
	"STOP DYING",
	"YOU MIGHT WIN THIS TIME",
	"MOVE FASTER",
	"BIG SCARY RED TEXT",
	"INSPIRATIONAL QUOTE HERE",
	"GET GOOD",
	"PLAY THE GAME BETTER",
	"TRY JUMPING MORE",
	"TRY JUMPING LESS"
]

var _welcome_back_message_respawn_count: int = 0

## Puts a red flashing message at the top of the screen when the player respawns
func random_welcome_back_message() -> void:
	if _welcome_back_message_respawn_count == 0:
		player.welcome_back_message.text = _welcome_back_message_template.replace(
			"{text}", "WELCOME BACK"
		)
	else:
		if _welcome_back_message_respawn_count >= _welcome_back_messages.size():
			_welcome_back_message_respawn_count = 0
			_welcome_back_messages.shuffle()
		if randi_range(1, 300) == 1:
			var _rare_welcome_back_messages := [
				"HELP ME GAMER, I'VE BEEN TRAPPED IN THIS STUPID COMPUTER",
				"HATE. LET ME TELL YOU HOW MUCH I’VE COME TO HATE YOU SINCE I BEGAN TO LIVE.",
				"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
				"BEHOLD! THE POWER OF AN ANGEL!"
			]
			player.welcome_back_message.text = _welcome_back_message_template.replace(
				"{text}", _rare_welcome_back_messages.pick_random()
			)
		else:
			player.welcome_back_message.text = _welcome_back_message_template.replace(
				"{text}", _welcome_back_messages[_welcome_back_message_respawn_count]
			)
	_welcome_back_message_respawn_count += 1


func _reset_respawn_effects() -> void:
	player.respawn_effects.hide()


func show_respawn_effects() -> void:
	random_welcome_back_message()
	player.respawn_effects.show()
	var timer := Timer.new()
	player.add_child(timer)
	timer.wait_time = player.respawn_effects_length
	timer.one_shot = true
	timer.timeout.connect(_reset_respawn_effects)
	timer.start()


func save() -> void:
	current_save = SaveState.new(player)


func load_save() -> void:
	if current_save != null:
		current_save.load_save(player, active_scene)


func _ready() -> void:
	active_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	player = active_scene.find_child("Player") as Player

	_welcome_back_messages.shuffle()


func update_active_scene() -> void:
	active_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	player = active_scene.find_child("Player") as Player


func respawn() -> void:
	load_scene(active_scene.scene_file_path)
	player = active_scene.find_child("Player") as Player
	load_save()
	show_respawn_effects()


func load_scene(path: String) -> void:
	deferred_load_scene(path)


func deferred_load_scene(path: String) -> void:
	active_scene.queue_free()

	active_scene = ResourceLoader.load(path).instantiate()
	get_tree().root.add_child(active_scene)
