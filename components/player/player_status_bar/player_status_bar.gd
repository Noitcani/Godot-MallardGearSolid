class_name PlayerStatusBar
extends HBoxContainer

@onready var rolling_cooldown_icon: TextureRect = %RollingCooldownIcon
@onready var rolling_cooldown_progress_bar: TextureProgressBar = %RollingCooldownProgressBar
@onready var shooting_cooldown_icon: TextureRect = %ShootingCooldownIcon
@onready var shooting_cooldown_progress_bar: TextureProgressBar = %ShootingCooldownProgressBar

@export var player: Player


func _process(_delta: float) -> void:
	if ! player.shot_cooldown_timer.is_stopped():
		shooting_cooldown_icon.visible = true
		var shot_cooldown_ratio: float = player.shot_cooldown_timer.time_left / player.shot_cooldown_interval
		shooting_cooldown_progress_bar.value = shot_cooldown_ratio
	else:
		shooting_cooldown_icon.visible = false
		
	if ! player.roll_cooldown_timer.is_stopped():
		rolling_cooldown_icon.visible = true
		var roll_cooldown_ratio: float = player.roll_cooldown_timer.time_left / player.roll_cooldown_interval
		rolling_cooldown_progress_bar.value = roll_cooldown_ratio
	else:
		rolling_cooldown_icon.visible = false	
