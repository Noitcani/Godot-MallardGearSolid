class_name EndScene
extends CanvasLayer

@export var survive_color: Color
@export var perish_color: Color

@onready var outcome_title_label: Label = %OutcomeTitleLabel
@onready var stats_container: PanelContainer = %StatsContainer
@onready var level_label: Label = %LevelLabel
@onready var days_survived_label: Label = %DaysSurvivedLabel
@onready var enemies_killed_label: Label = %EnemiesKilledLabel
@onready var shots_accuracy_label: Label = %ShotsAccuracyLabel
@onready var takedown_label: Label = %TakedownLabel
@onready var play_again_button: Button = %PlayAgainButton

@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var screen_transitions_manager: ScreenTransitionsManagerClass = ScreenTransitionsManager
@onready var audio_manager: AudioManagerClass = AudioManager

var outcome: String
var stats_dict: Dictionary


func _init_scene() -> void:
	outcome = resource_manager.outcome
	stats_dict = resource_manager.stats_dict
	
	if outcome == "win":
		outcome_title_label.text = "You Survived\nTill Extraction"
		outcome_title_label.add_theme_color_override("font_color", survive_color)
	else:
		outcome_title_label.text = "You Perished\nBefore Extraction"
		outcome_title_label.add_theme_color_override("font_color", perish_color)
	
	level_label.text = str("%02d" % stats_dict.get("level"))
	days_survived_label.text = str("%02d" % stats_dict.get("days_survived"))
	enemies_killed_label.text = str("%02d" % stats_dict.get("enemies_killed"))
	shots_accuracy_label.text = str("%.1f" % (stats_dict.get("shots_accuracy") * 100) ) + "%"
	takedown_label.text = str("%02d" % stats_dict.get("enemys_takedown"))


func _on_play_again_button_pressed() -> void:
	audio_manager.dim_and_kill_all_streams()
	audio_manager.play_sfx(audio_manager.MENU_SELECT, "MENU_SELECT")
	screen_transitions_manager.change_scene_to_packed_scene(resource_manager.MAIN_MENU)


func _ready() -> void:
	audio_manager.dim_and_kill_all_streams()
	audio_manager.play_music(audio_manager.VICTORY_OR_GAME_OVER_1, "VICTORY_OR_GAME_OVER_1")
	screen_transitions_manager.mask_off()
	_init_scene()
	play_again_button.pressed.connect(_on_play_again_button_pressed)
	
