extends Control

var master_volume_slider: Slider
var music_volume_slider: Slider
var sound_effects_volume_slider: Slider
var full_screen_checkbox: CheckButton


func _enter_tree() -> void:
	master_volume_slider = $OptionsVertBox/MasterVolumeSlider
	music_volume_slider = $OptionsVertBox/MusicVolumeSlider
	sound_effects_volume_slider = $OptionsVertBox/SoundEffetsVolumeSlider
	full_screen_checkbox = $OptionsVertBox/FullScreenLabel/FullScreenCheck
	OptionsManager.options_loaded.connect(_load_values)


func _load_values(_options: Dictionary) -> void:
	master_volume_slider.value = OptionsManager.get_option("audio", "master")
	music_volume_slider.value = OptionsManager.get_option("audio", "music")
	sound_effects_volume_slider.value = OptionsManager.get_option("audio", "sound_effects")
	full_screen_checkbox.button_pressed = OptionsManager.get_option("graphics", "full_screen")
	if OptionsManager.get_option("graphics", "full_screen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_master_volume_slider_value_changed(value: float) -> void:
	OptionsManager.set_option_without_saving("audio", "master", value)


func _on_master_volume_slider_drag_ended(_value_changed: bool) -> void:
	OptionsManager.save()


func _on_music_volume_slider_value_changed(value: float) -> void:
	OptionsManager.set_option_without_saving("audio", "music", value)


func _on_music_volume_slider_drag_ended(_value_changed: bool) -> void:
	OptionsManager.save()


func _on_sound_effets_volume_slider_value_changed(value: float) -> void:
	OptionsManager.set_option_without_saving("audio", "sound_effects", value)


func _on_sound_effets_volume_slider_drag_ended(_value_changed: bool) -> void:
	OptionsManager.save()


func _on_full_screen_check_toggled(toggled_on: bool) -> void:
	OptionsManager.set_option("graphics", "full_screen", toggled_on)
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
