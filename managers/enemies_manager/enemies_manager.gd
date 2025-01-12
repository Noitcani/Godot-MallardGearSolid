class_name EnemiesManager
extends Node

@onready var spawn_timer: Timer = %SpawnTimer

@onready var play_scene: PlayScene = get_tree().get_first_node_in_group("play_scene")
@onready var play_area: PlayArea = get_tree().get_first_node_in_group("play_area")
@onready var game_progression_manager: GameProgressionManager = get_tree().get_first_node_in_group("game_progression_manager")

@onready var signals_manager: SignalsManagerClass = SignalsManager
@onready var resource_manager: ResourceManagerClass = ResourceManager

var total_num_enemies_to_spawn_today: int
var num_enemies_left_to_spawn: int

var enemy_hp: int = 10
var enemy_reload_time: float = 3
var enemy_shooting_range: float = 500
var enemy_bullet_damage: float = 1
var enemy_bullet_speed: float = 700
var patrol_movement_speed: float = 100
var chasing_movement_speed: float = 150
var enemy_idle_duration: float = 2


func _on_new_day(_day_count: int) -> void:
	spawn_timer.stop()
	total_num_enemies_to_spawn_today = game_progression_manager.number_of_enemies_to_spawn_on_next_day
	num_enemies_left_to_spawn = total_num_enemies_to_spawn_today
	spawn_timer.wait_time = ( game_progression_manager.day_night_interval * 2 ) / total_num_enemies_to_spawn_today
	spawn_timer.start()
	spawn_first_enemy_of_day()


func _spawn_enemy() -> void:
	var spawn_pos: Vector2 = play_area.get_random_spawn_point_pos()
	var enemy_instance: Enemy = resource_manager.ENEMY.instantiate() as Enemy
	_init_enemy(enemy_instance)
	enemy_instance.global_position = spawn_pos
	play_scene.enemies_layer.add_child(enemy_instance)
	num_enemies_left_to_spawn = max(0, num_enemies_left_to_spawn - 1)
	if num_enemies_left_to_spawn == 0:
		spawn_timer.stop()


func _init_enemy(enemy_instance: Enemy) -> void:
	enemy_instance.play_scene = play_scene
	enemy_instance.enemies_manager = self
	enemy_instance.max_hp = enemy_hp
	enemy_instance.reload_time = enemy_reload_time
	enemy_instance.shooting_range = enemy_shooting_range
	enemy_instance.bullet_damage = enemy_bullet_damage
	enemy_instance.patrol_movement_speed = patrol_movement_speed
	enemy_instance.chasing_movement_speed = chasing_movement_speed
	enemy_instance.bullet_speed = enemy_bullet_speed
	enemy_instance.idle_duration = enemy_idle_duration


func _on_spawn_timer_timeout() -> void:
	_spawn_enemy()


func _ready() -> void:
	signals_manager.new_day.connect(_on_new_day)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func spawn_first_enemy_of_day() -> void:
	var spawn_pos: Vector2 = play_area.enemy_spawn_points_layer.get_child(0).get("global_position")
	var enemy_instance: Enemy = resource_manager.ENEMY.instantiate() as Enemy
	_init_enemy(enemy_instance)
	enemy_instance.global_position = spawn_pos
	play_scene.enemies_layer.add_child(enemy_instance)
