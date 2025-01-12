extends CanvasLayer

@onready var logos_container: HBoxContainer = $LogosContainer

@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var screen_transitions_manager: ScreenTransitionsManagerClass = ScreenTransitionsManager
@onready var audio_manager: AudioManagerClass = AudioManager


func _ready() -> void:
	audio_manager.play_music(audio_manager.TITLE_SCREEN, "TITLE_SCREEN")
	logos_container.modulate.a = 0
	var tween: Tween = create_tween()
	tween.tween_property(logos_container, "modulate:a", 1, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_interval(1)
	tween.tween_property(logos_container, "modulate:a", 0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_interval(1)
	await tween.finished
	screen_transitions_manager.change_scene_to_packed_scene(resource_manager.MAIN_MENU)
