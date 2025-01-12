extends EnemyState

@onready var idle_timer: Timer = %IdleTimer

var game_progression_manager: GameProgressionManager


func _ready() -> void:
	idle_timer.timeout.connect(_on_idle_timer_timeout)


func _on_idle_timer_timeout() -> void:
	if game_progression_manager.current_phase == "day":
		transition_to_state("DayPatrol")
	elif game_progression_manager.current_phase == "night":
		transition_to_state("Patrol")


func override_process(_delta: float) -> void:
	pass


func override_physics_process(_delta: float) -> void:
	enemy_parent.velocity = Vector2.ZERO


func enter_state(_params: Dictionary = {}) -> void:
	var idle_time: float = randf_range(0, enemy_parent.idle_duration)
	game_progression_manager = get_tree().get_first_node_in_group("game_progression_manager")
	if enemy_parent.animated_sprite_2d:
		enemy_parent.animated_sprite_2d.stop()
	idle_timer.start(idle_time)


func exit_state(_params: Dictionary = {}) -> void:
	enemy_parent.animated_sprite_2d.play()
	idle_timer.stop()
