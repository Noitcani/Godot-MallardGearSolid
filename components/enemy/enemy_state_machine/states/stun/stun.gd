extends EnemyState

@onready var takedown_interval_timer: Timer = %TakedownIntervalTimer

@onready var audio_manager: AudioManagerClass = AudioManager

var alerted_allies_array: Array[Enemy]


func _ready() -> void:
	takedown_interval_timer.timeout.connect(_on_takedown_timer_timeout)


func _compile_alerted_allies() -> void:
	for body in enemy_parent.allies_alert_radius.get_overlapping_bodies():
		if body is Enemy and body != enemy_parent:
			alerted_allies_array.append(body)


func _on_takedown_timer_timeout() -> void:
	player.player_camera.apply_screen_shake()
	enemy_parent.hp_component.take_damage(2)
	player.hp_component.take_heal(1)
	player.current_ammo = min( player.max_ammo_capacity, player.current_ammo + 1 )


func _input(event: InputEvent) -> void:
	if enemy_state_machine.current_state == self:
		if event.is_action_released("attack"):
			transition_to_state("Idle")
	

func override_process(_delta: float) -> void:
	pass


func override_physics_process(_delta: float) -> void:
	enemy_parent.velocity = Vector2.ZERO


func enter_state(_params: Dictionary = {}) -> void:
	enemy_parent.animated_sprite_2d.hide()
	enemy_parent.velocity = Vector2.ZERO
	randomize()
	if randf() < 0.5:
		audio_manager.play_sfx(audio_manager.takedown_choke1, "takedown_choke1")
	else:
		audio_manager.play_sfx(audio_manager.takedown_choke2, "takedown_choke2")
	
	takedown_interval_timer.wait_time = enemy_parent.take_down_interval
	
	alerted_allies_array = []
	_compile_alerted_allies()
	for ally in alerted_allies_array:
		if is_instance_valid(ally) and ! ally.is_queued_for_deletion():
			if ally.enemy_state_machine.current_state == ally.enemy_state_machine.idle or ally.enemy_state_machine.current_state == ally.enemy_state_machine.patrol:
				ally.enemy_state_machine.current_state.transition_to_state("Alerted", {"source" : enemy_parent})

	enemy_parent.lightsource.hide()
	takedown_interval_timer.start()


func exit_state(_params: Dictionary = {}) -> void:
	if audio_manager.has_node("takedown_choke1"):
		audio_manager.get_node("takedown_choke1").queue_free()
	if audio_manager.has_node("takedown_choke2"):
		audio_manager.get_node("takedown_choke2").queue_free()
	
	enemy_parent.animated_sprite_2d.show()
	enemy_parent.lightsource.show()
	takedown_interval_timer.stop()
	
	for ally in alerted_allies_array:
		if is_instance_valid(ally) and ! ally.is_queued_for_deletion():
			if ally.enemy_state_machine.current_state == ally.enemy_state_machine.alerted:
				ally.enemy_state_machine.current_state.transition_to_state("Idle")
