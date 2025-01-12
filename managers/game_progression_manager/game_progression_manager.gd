class_name GameProgressionManager
extends Node

@export var day_night_interval: float = 30

@onready var day_night_timer: Timer = %DayNightTimer

@onready var signals_manager: SignalsManagerClass = SignalsManager
@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var play_scene: PlayScene = get_tree().get_first_node_in_group("play_scene")
@onready var hud: HUD = get_tree().get_first_node_in_group("hud")

var day_count: int = 0
var current_phase: String = "day"
var next_phase: String = "night"

var number_of_enemies_to_spawn_on_next_day: int = 4
var number_of_enemies_increment_per_day: int = 1

var enemies_killed: int:
	set(new_amount):
		enemies_killed = new_amount
		hud.enemies_killed_label.text = str("%02d" % enemies_killed)

var player_current_level: int:
	set(new_level):
		player_current_level = new_level
		hud.player_level_label.text = str("%02d" % player_current_level)

var target_exp_to_next_level: float:
	set(new_target):
		target_exp_to_next_level = new_target
		hud.exp_bar.max_value = target_exp_to_next_level
		
var current_exp: float:
	set(new_exp):
		current_exp = new_exp
		hud.exp_bar.value = current_exp
		if current_exp >= target_exp_to_next_level:
			_spawn_upgrade_overlay()

var experience_increment_factor_per_level: float = 1

var shots_fired: float
var shots_landed: float
var enemies_takedown_kills: int


func _init_game_progress() -> void:
	current_phase = "day"
	player_current_level = 1
	target_exp_to_next_level = 3
	current_exp = 0
	enemies_killed = 0


func _on_day_night_timer_timeout() -> void:
	next_phase = current_phase
	
	if current_phase == "day":
		current_phase = "night"
		signals_manager.new_night.emit()
		return
		
	if current_phase == "night":
		current_phase = "day"
		number_of_enemies_to_spawn_on_next_day += number_of_enemies_increment_per_day
		day_count += 1
		signals_manager.new_day.emit(day_count)
		return


func _spawn_upgrade_overlay() -> void:
	var upgrade_overlay_instance: UpgradeChoicesOverlay = resource_manager.UPGRADE_CHOICES_OVERLAY.instantiate() as UpgradeChoicesOverlay
	play_scene.add_child(upgrade_overlay_instance)
	get_tree().paused = true


func _on_game_start() -> void:
	_init_game_progress()
	signals_manager.new_day.emit(day_count)
	day_night_timer.start(day_night_interval)


func _ready() -> void:
	day_night_timer.wait_time = day_night_interval
	day_night_timer.timeout.connect(_on_day_night_timer_timeout)


func start_game() -> void:
	_on_game_start()


func level_up_complete() -> void:
	player_current_level += 1
	current_exp = 0
	target_exp_to_next_level = target_exp_to_next_level + experience_increment_factor_per_level


func get_stats_dict() -> Dictionary:
	var stats_dict: Dictionary = {
		"days_survived" : day_count,
		"level" : player_current_level,
		"enemies_killed" : enemies_killed,
		"shots_accuracy" : shots_landed / shots_fired,
		"enemys_takedown" : enemies_takedown_kills,
	}
	return stats_dict
