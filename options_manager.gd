extends Node

const default_options: Dictionary = {
	"test" = 5,
	"test_2" = 10,
	"test_3" = "what the fuck"
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
			options[key] = config.get_value(section, key)
	set_option("test", 234892934)
	save()

func reset() -> void:
	for key: String in default_options.keys():
		options[key] = default_options[key]
	save()

func save() -> void:
	for key: String in options.keys():
		config.set_value("options", key, options[key])
	config.save("user://options.cfg")

func get_option(key: String) -> Variant:
	return options[key]
	
func set_option(key: String, value: Variant) -> void:
	if get_option(key) == value:
		return
	options[key] = value
	save()
