extends EnemyState

@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var audio_manager: AudioManagerClass = AudioManager


func _shoot_bullet() -> void:
	var bullet_instance: Bullet = resource_manager.BULLET.instantiate() as Bullet
	bullet_instance.bullet_source = enemy_parent
	bullet_instance.global_position = enemy_parent.muzzle_marker.global_position
	
	var direction: Vector2 = enemy_parent.muzzle_marker.global_position.direction_to(player.global_position)
	bullet_instance.direction = direction
	bullet_instance.bullet_damage = enemy_parent.bullet_damage
	bullet_instance.bullet_speed = enemy_parent.bullet_speed
	play_scene.bullets_layer.add_child(bullet_instance)
	audio_manager.play_sfx( audio_manager.enemy_gunshot_sounds.pick_random() as AudioStream, "enemy_gunshot" )
	
	transition_to_state("DayPatrol", {"reload_time" : enemy_parent.reload_time})


func enter_state(_params: Dictionary = {}) -> void:
	_shoot_bullet()


func exit_state(_params: Dictionary = {}) -> void:
	pass
