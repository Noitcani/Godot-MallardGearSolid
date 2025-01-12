class_name EnemySpawnPoint
extends Marker2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

var is_active: bool

func _process(_delta: float) -> void:
	is_active = ! visible_on_screen_notifier_2d.is_on_screen()
