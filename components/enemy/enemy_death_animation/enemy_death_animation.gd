class_name EnemyDeathAnimation
extends AnimatedSprite2D


func _fade_out_tween() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 2)
	await tween.finished


func _ready() -> void:
	await _fade_out_tween()
	queue_free()
