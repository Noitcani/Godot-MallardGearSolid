extends EnemyState

var random_direction: Vector2
var random_destination: Vector2

var navigation_agent: NavigationAgent2D
var destination_chosen: bool


func _set_movement_target(movement_target: Vector2) -> void:
	navigation_agent.set_target_position(movement_target)


func _check_nav_and_move() -> void:
	if navigation_agent.is_navigation_finished():
		transition_to_state("Idle")
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = enemy_parent.global_position.direction_to(next_path_position) * enemy_parent.patrol_movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	enemy_parent.velocity = safe_velocity
	enemy_parent.move_and_slide()


func _rotate_to_face_destination(delta: float) -> void:
	var direction: Vector2 = enemy_parent.velocity.normalized()
	var angle_to: float = enemy_parent.pivot_point.transform.x.angle_to(direction)
	var rotation_amount: float = sign(angle_to) * min(delta * enemy_parent.rotation_speed, abs(angle_to))
	enemy_parent.pivot_point.rotate( rotation_amount )


func override_process(_delta: float) -> void:
	pass


func override_physics_process(_delta: float) -> void:
	if destination_chosen:
		var direction: Vector2 = enemy_parent.velocity.normalized()
		if abs(enemy_parent.transform.x.angle_to(direction)) > 0.05:
			_rotate_to_face_destination(_delta)
			
		_check_nav_and_move()


func enter_state(_params: Dictionary = {}) -> void:
	navigation_agent = enemy_parent.navigation_agent_2d
	if ! navigation_agent.velocity_computed.is_connected(_on_velocity_computed):
		navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	## Generate random destination
	while true:
		var random_direction_angle: float = randf_range(0, TAU)
		random_direction = Vector2.ONE.rotated( random_direction_angle ).normalized()
		random_destination = enemy_parent.global_position + ( random_direction * randf_range( enemy_parent.min_move_distance, enemy_parent.max_move_distance ) )
		var tile_map_cell: Vector2i =  play_area.play_area_tilemap.local_to_map(random_destination)
		if play_area.play_area_tilemap.floor.get_cell_tile_data(tile_map_cell):
			break
	
	_set_movement_target(random_destination)
	destination_chosen = true


func exit_state(_params: Dictionary = {}) -> void:
	if navigation_agent.velocity_computed.is_connected(_on_velocity_computed):
		navigation_agent.velocity_computed.disconnect(Callable(_on_velocity_computed))
	
	destination_chosen = false
	_set_movement_target(enemy_parent.global_position)
	enemy_parent.velocity = Vector2.ZERO
