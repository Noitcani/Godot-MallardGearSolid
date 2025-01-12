class_name Upgrade
extends Resource

@export_enum("buff", "debuff") var upgrade_type: String
@export var upgrade_name: String
@export var upgrade_description: String


func apply_effects(_player: Player, _play_scene: PlayScene) -> void:
	pass
