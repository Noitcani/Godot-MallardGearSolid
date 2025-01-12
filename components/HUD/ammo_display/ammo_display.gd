class_name AmmoDisplay
extends TextureRect

@export var enabled_color: Color
@export var disabled_color: Color


func enable_ammo_display(is_on: bool) -> void:
	if is_on:
		modulate = enabled_color
	else:
		modulate = disabled_color
