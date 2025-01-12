extends Upgrade

func apply_effects(_player: Player, _play_scene: PlayScene) -> void:
	_player.reload_time = _player.reload_time * 0.9
