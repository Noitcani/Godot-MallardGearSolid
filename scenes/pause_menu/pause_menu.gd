extends CanvasLayer

@onready var continue_button: Button = %ContinueButton
@onready var options: Button = %Options
@onready var return_to_mm: Button = %Return_to_mm
@onready var quit: Button = %Quit

@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var screen_transitions_manager: ScreenTransitionsManagerClass = ScreenTransitionsManager
@onready var audio_manager: AudioManagerClass = AudioManager


func _on_continue_pressed()->void:
	audio_manager.play_sfx(audio_manager.MENU_EXIT, "MENU_EXIT")
	enable_all_buttons(false)
	if visible:
		hide()
		get_tree().paused = false
		return


func _on_options_pressed()->void:
	audio_manager.play_sfx(audio_manager.OPEN_MENU_001, "OPEN_MENU_001")
	enable_all_buttons(false)
	var settings_popup_instance: SettingsPopup = resource_manager.SETTINGS_POPUP.instantiate() as SettingsPopup
	settings_popup_instance.settings_popup_closed.connect(enable_all_buttons.bind(true))
	add_child(settings_popup_instance)


func _on_quit_pressed()->void:
	audio_manager.play_sfx(audio_manager.MENU_EXIT, "MENU_EXIT")
	enable_all_buttons(false)
	get_tree().quit()


func _on_return_to_mm_pressed()->void:
	audio_manager.play_sfx(audio_manager.MENU_EXIT, "MENU_EXIT")
	enable_all_buttons(false)
	get_tree().paused = false
	screen_transitions_manager.change_scene_to_packed_scene(resource_manager.MAIN_MENU)


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	options.pressed.connect(_on_options_pressed)
	return_to_mm.pressed.connect(_on_return_to_mm_pressed)
	quit.pressed.connect(_on_quit_pressed)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		if ! visible and ! get_tree().paused:
			audio_manager.play_sfx(audio_manager.OPEN_MENU_001, "OPEN_MENU_001")
			show()
			enable_all_buttons(true)
			get_tree().paused = true
			return

		if visible:
			audio_manager.play_sfx(audio_manager.MENU_EXIT, "MENU_EXIT")
			hide()
			get_tree().paused = false
			return


func enable_all_buttons(is_on: bool) -> void:
	continue_button.disabled = ! is_on
	options.disabled = ! is_on
	return_to_mm.disabled = ! is_on
	quit.disabled = ! is_on
