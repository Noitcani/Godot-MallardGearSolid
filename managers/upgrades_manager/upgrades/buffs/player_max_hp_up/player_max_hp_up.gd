extends Upgrade

func apply_effects(_player: Player, _play_scene: PlayScene) -> void:
	_player.hp_component.max_hp += 5
