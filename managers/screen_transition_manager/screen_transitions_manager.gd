class_name ScreenTransitionsManagerClass
extends Node

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var mask: ColorRect = $CanvasLayer/Mask


var fading: bool
var is_mask_on: bool 

func _reset() -> void:
	fading = false
	canvas_layer.hide()
	mask.modulate.a = 0
	mask.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	_reset()
	

func mask_on(mask_color: Color = Color.BLACK, fade_time: float = 0.5) -> void:
	if is_mask_on or fading: return
	mask.mouse_filter = Control.MOUSE_FILTER_STOP
	fading = true
	mask.modulate = mask_color
	mask.modulate.a = 0
	canvas_layer.show()
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(mask, "modulate", mask_color, fade_time)
	tween.tween_property(self, "fading", false, 0)
	is_mask_on = true
	await tween.finished


func mask_off(fade_time: float = 0.5) -> void:
	if ! is_mask_on or fading: return
	fading = true
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(mask, "modulate:a", 0, fade_time)
	tween.tween_callback(canvas_layer.hide)
	tween.tween_property(self, "fading", false, 0)
	is_mask_on = false
	await tween.finished
	mask.mouse_filter = Control.MOUSE_FILTER_IGNORE


func change_scene_to_packed_scene(next_scene: PackedScene) -> void:
	await mask_on()
	get_tree().change_scene_to_packed(next_scene)


func change_scene_to_filepath(next_scene_path: String) -> void:
	await mask_on()
	get_tree().change_scene_to_file(next_scene_path)
