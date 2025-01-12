extends EnemyState

var source: Enemy


func _tween_lightsource_scale(to_scale_factor: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(enemy_parent.lightsource, "scale", Vector2( to_scale_factor, to_scale_factor ), 0.5)


func _rotate_to_face_destination(destination: Vector2, delta: float) -> void:
	var direction: Vector2 = destination - enemy_parent.global_position
	var angle_to: float = enemy_parent.pivot_point.transform.x.angle_to(direction)
	var rotation_amount: float = sign(angle_to) * min(delta * enemy_parent.rotation_speed, abs(angle_to))
	enemy_parent.pivot_point.rotate( rotation_amount )


func override_process(_delta: float) -> void:
	pass


func override_physics_process(_delta: float) -> void:
	if is_instance_valid(source) and ! source.is_queued_for_deletion():
		var direction: Vector2 = source.global_position - enemy_parent.global_position
		if abs(enemy_parent.transform.x.angle_to(direction)) > 0.05:
			_rotate_to_face_destination( source.global_position, _delta )
			return

		if enemy_parent.global_position.distance_squared_to(source.global_position) > 5 :
			var direction_to_destination: Vector2 = enemy_parent.global_position.direction_to(source.global_position).normalized()
			enemy_parent.velocity = enemy_parent.patrol_movement_speed * direction_to_destination
			enemy_parent.move_and_slide()

	else:
		transition_to_state("Idle")


func enter_state(_params: Dictionary = {}) -> void:
	enemy_parent.status_alert_sprite.play("alerted")
	source = _params["source"]
	if enemy_parent.lightsource.lightsource_active and play_scene.game_progression_manager.current_phase == "night":
		_tween_lightsource_scale(1.2)
	
	
func exit_state(_params: Dictionary = {}) -> void:
	enemy_parent.status_alert_sprite.play("default")
	if enemy_parent.lightsource.lightsource_active and play_scene.game_progression_manager.current_phase == "night":
		_tween_lightsource_scale(1)
