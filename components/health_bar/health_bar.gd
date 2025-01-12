class_name HealthBar
extends CenterContainer
## Health bar. Displays amount of health left

## Gradient resource to shade bar based on amount of health left.
@export var gradient: Gradient
## Progress bar node
@onready var progress_bar: ProgressBar = $ProgressBar


## Health bar value. Setter to update color of health bar based on amount of health left.
var health_bar_value: float:
	set(new_value):
		health_bar_value = new_value
		progress_bar.value = health_bar_value
		_update_progress_bar(health_bar_value)


## Updates value of health bar, and changes color based on amount of health left.
func _update_progress_bar(value: float) -> void:
	progress_bar.value = value
	var style_box_fill: StyleBoxFlat = progress_bar.get("theme_override_styles/fill")
	style_box_fill.set("bg_color", gradient.sample(value))	


func _ready() -> void:
	health_bar_value = 1.0
