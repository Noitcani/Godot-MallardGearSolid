class_name SettingsPopup
extends Control

signal settings_popup_closed

@onready var master_bus_slider: HSlider = %MasterBusSlider
@onready var music_bus_slider: HSlider = %MusicBusSlider
@onready var sfx_bus_slider: HSlider = %SFXBusSlider
@onready var confirm_button: Button = %ConfirmButton

@onready var audio_manager: AudioManagerClass = AudioManager

var sliders_array: Array[HSlider]


func _connect_slider_signals() -> void:
	for slider in sliders_array:
		slider.value_changed.connect(_on_slider_value_changed.bind(slider))


func _on_slider_value_changed(value: float, slider: HSlider) -> void:
	match slider:
		master_bus_slider:
			AudioServer.set_bus_volume_db(0, linear_to_db(value))
		music_bus_slider:
			AudioServer.set_bus_volume_db(1, linear_to_db(value))
		sfx_bus_slider:
			AudioServer.set_bus_volume_db(2, linear_to_db(value))


func _set_sliders_value() -> void:
	for slider in sliders_array:
		slider.value = db_to_linear(AudioServer.get_bus_volume_db(sliders_array.find(slider)))


func _on_confirm_button_pressed() -> void:
	await VfxUtils2D.fade_out(self, 0.4, false)
	settings_popup_closed.emit()
	queue_free()


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	sliders_array = [master_bus_slider, music_bus_slider, sfx_bus_slider]
	_connect_slider_signals()
	_set_sliders_value()
