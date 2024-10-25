extends Node

const default_options: Dictionary = {
	"audio.master" = 100,
	"audio.music" = 100,
	"audio.sound_effects" = 100,
	"graphics.full_screen" = false
}

var options: Dictionary = default_options.duplicate(true)
var config: ConfigFile = ConfigFile.new()

func _enter_tree() -> void:
	var err := config.load("user://options.cfg")
	if err != OK:
		reset()
		return
	for section in config.get_sections():
		for key in config.get_section_keys(section):
			options[section + "." + key] = config.get_value(section, key)
	save()

func reset() -> void:
	for key: String in default_options.keys():
		options[key] = default_options[key]
	save()

func save() -> void:
	for key: String in options.keys():
		var sectionkey := key.split(".")
		config.set_value(sectionkey[0], sectionkey[1], options[key])
	config.save("user://options.cfg")

func get_option(section: String, key: String) -> Variant:
	if options[section + "." + key] == null:
		options[section + "." + key] = default_options[section + "." + key]
	return options[section + "." + key]
	
func set_option(section: String, key: String, value: Variant) -> void:
	if get_option(section, key) == value:
		return
	options[section + "." + key] = value
	save()
