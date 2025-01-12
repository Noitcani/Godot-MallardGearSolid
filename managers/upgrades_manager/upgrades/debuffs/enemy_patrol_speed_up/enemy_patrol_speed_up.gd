extends Upgrade

func apply_effects(_player: Player, _play_scene: PlayScene) -> void:
	_play_scene.enemies_manager.patrol_movement_speed *= 1.1
