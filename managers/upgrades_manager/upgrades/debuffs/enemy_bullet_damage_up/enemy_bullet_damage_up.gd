extends Upgrade

func apply_effects(_player: Player, _play_scene: PlayScene) -> void:
	_play_scene.enemies_manager.enemy_shooting_range *= 1.1
