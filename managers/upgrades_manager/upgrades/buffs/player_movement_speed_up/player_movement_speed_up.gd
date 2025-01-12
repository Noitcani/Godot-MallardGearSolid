extends Upgrade

func apply_effects(_player: Player, _play_scene: PlayScene) -> void:
	_player.move_speed *= 1.1
