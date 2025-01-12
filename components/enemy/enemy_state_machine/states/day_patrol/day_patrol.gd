extends EnemyState

@export var min_day_patrol_duration: float = 8
@export var max_day_patrol_duration: float = 12
@onready var day_patrol_timer: Timer = %DayPatrolTimer
@onready var reload_timer: Timer = %ReloadTimer

var navigation_agent: NavigationAgent2D
var in_patrol: bool = true


func _set_movement_target(movement_target: Vector2) -> void:
	navigation_agent.set_target_position(movement_target)


func _check_nav_and_move() -> void:	
	if navigation_agent.is_navigation_finished():
		transition_to_state("Idle")
		enemy_parent.velocity = Vector2.ZERO
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var movement_speed: float = enemy_parent.patrol_movement_speed
	enemy_parent.status_alert_sprite.play("default")
	
	if play_scene.sun.sun_lightsource.light_hitting_player:
		if enemy_parent.status_alert_sprite.animation != "chase":
			enemy_parent.status_alert_sprite.play("chase")
		movement_speed = enemy_parent.chasing_movement_speed

	var new_velocity: Vector2 = enemy_parent.global_position.direction_to(next_path_position) * movement_speed
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	enemy_parent.velocity = safe_velocity
	enemy_parent.move_and_slide()


func _rotate_to_face_destination(delta: float) -> void:
	var direction: Vector2 = enemy_parent.velocity.normalized()
	if player.global_position.distance_to(enemy_parent.global_position) <= enemy_parent.shooting_range:
		direction = enemy_parent.global_position.direction_to(player.global_position)
	
	var angle_to: float = enemy_parent.pivot_point.transform.x.angle_to(direction)
	var rotation_amount: float = sign(angle_to) * min(delta * enemy_parent.rotation_speed, abs(angle_to))
	enemy_parent.pivot_point.rotate( rotation_amount )


func _on_day_patrol_timer_timeout() -> void:
	transition_to_state("Idle")


func _ready() -> void:
	day_patrol_timer.timeout.connect(_on_day_patrol_timer_timeout)
	pass


func override_process(_delta: float) -> void:
	pass


func override_physics_process(_delta: float) -> void:
	if reload_timer.is_stopped():
		enemy_parent.shooting_raycast.force_raycast_update()
		if enemy_parent.shooting_raycast.is_colliding():
			if enemy_parent.shooting_raycast.get_collider() is Player:
				transition_to_state("DayShoot")
	
	if in_patrol:
		_set_movement_target(player.global_position)
		var direction: Vector2 = enemy_parent.velocity.normalized()
		if abs(enemy_parent.transform.x.angle_to(direction)) > 0.05:
			_rotate_to_face_destination(_delta)

		_check_nav_and_move()


func enter_state(_params: Dictionary = {}) -> void:
	day_patrol_timer.wait_time = randf_range(min_day_patrol_duration, max_day_patrol_duration)
	day_patrol_timer.start()
	
	if _params.get("reload_time"):
		var reload_time: float = _params["reload_time"]
		reload_timer.start(reload_time)
	
	navigation_agent = enemy_parent.navigation_agent_2d
	if ! navigation_agent.velocity_computed.is_connected(_on_velocity_computed):
		navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	in_patrol = true


func exit_state(_params: Dictionary = {}) -> void:
	enemy_parent.status_alert_sprite.play("default")
	if navigation_agent.velocity_computed.is_connected(_on_velocity_computed):
		navigation_agent.velocity_computed.disconnect(Callable(_on_velocity_computed))
	
	in_patrol = false
	_set_movement_target(enemy_parent.global_position)
	enemy_parent.velocity = Vector2.ZERO
