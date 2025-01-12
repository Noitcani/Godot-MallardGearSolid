extends CanvasLayer

@onready var button: Button = %Button

@onready var audio_manager: AudioManagerClass = AudioManager


func _on_button_pressed() -> void:
	audio_manager.play_sfx(audio_manager.MENU_EXIT, "MENU_EXIT")
	get_tree().paused = false
	queue_free()


func _ready() -> void:
	audio_manager.play_sfx(audio_manager.MENU_SELECT, "MENU_SELECT")
	button.pressed.connect(_on_button_pressed)
