class_name MainMenu
extends Control

@onready var start: Button = %Start
@onready var options: Button = %Options
@onready var quit: Button = %Quit

@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var screen_transitions_manager: ScreenTransitionsManagerClass = ScreenTransitionsManager
@onready var audio_manager: AudioManagerClass = AudioManager


func _on_start_pressed() -> void:
	audio_manager.play_sfx(audio_manager.START_GAME, "START_GAME")
	enable_all_buttons(false)
	print("Start pressed")
	if ! resource_manager.has_intro_narrative_played:
		resource_manager.has_intro_narrative_played = true
		screen_transitions_manager.change_scene_to_packed_scene(resource_manager.NARRATIVE_SCENE)
	
	else:
		screen_transitions_manager.change_scene_to_packed_scene(resource_manager.PLAY_SCENE)


func _on_options_pressed() -> void:
	audio_manager.play_sfx(audio_manager.OPEN_MENU_001, "OPEN_MENU_001")
	print("options pressed")
	enable_all_buttons(false)
	var settings_popup_instance: SettingsPopup = resource_manager.SETTINGS_POPUP.instantiate() as SettingsPopup
	settings_popup_instance.settings_popup_closed.connect(enable_all_buttons.bind(true))
	add_child(settings_popup_instance)


func _on_quit_pressed() -> void:
	enable_all_buttons(false)
	print("quit pressed")
	get_tree().quit()


func _ready() -> void:
	resource_manager.reset()
	if ! audio_manager.music_layer.has_node("TITLE_SCREEN"):
		audio_manager.play_music(audio_manager.TITLE_SCREEN, "TITLE_SCREEN")
	
	screen_transitions_manager.mask_off()
	start.pressed.connect(_on_start_pressed)
	options.pressed.connect(_on_options_pressed)
	quit.pressed.connect(_on_quit_pressed)


func enable_all_buttons(is_on: bool) -> void:
	start.disabled = !is_on
	options.disabled = !is_on
	quit.disabled = !is_on
