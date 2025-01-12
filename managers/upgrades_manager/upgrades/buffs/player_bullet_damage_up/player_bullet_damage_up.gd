extends Upgrade

func apply_effects(_player: Player, _play_scene: PlayScene) -> void:
	_player.bullet_damage += 2
