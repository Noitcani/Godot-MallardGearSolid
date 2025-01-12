extends Upgrade

func apply_effects(_player: Player, _play_scene: PlayScene) -> void:
	_player.roll_duration *= 1.2
