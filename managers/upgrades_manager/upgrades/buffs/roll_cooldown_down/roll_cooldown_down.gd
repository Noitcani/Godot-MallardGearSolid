extends Upgrade

func apply_effects(_player: Player, _play_scene: PlayScene) -> void:
	_player.roll_cooldown_interval *= 0.9
