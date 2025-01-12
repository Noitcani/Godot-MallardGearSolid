class_name VfxUtils2D
extends Node

## Compilation of static functions for commonly used tweens and vfx by code.


## Fade in (modulate to 1) over fade_time.
static func fade_in(subject: CanvasItem, fade_time: float = 0.5, skippable: bool = true) -> void:
	subject.modulate.a = 0
	var tween: Tween = subject.create_tween()
	if skippable:
		TweenManager.call("register_tween_to_array", tween)
	tween.tween_property(subject, "modulate:a", 1, fade_time)
	await tween.finished
	
	
## Fade out (modulate to 0) over fade_time. Requires initial modulate to be >0.
static func fade_out(subject: CanvasItem, fade_time: float = 0.5, stay_time: float = 0, skippable: bool = true) -> void:
	var tween: Tween = subject.create_tween()
	if skippable:
		TweenManager.call("register_tween_to_array", tween)
	tween.tween_interval(stay_time)
	tween.tween_property(subject, "modulate:a", 0, fade_time)
	await tween.finished


## Fade in, stay, fade out
static func fade_in_stay_out(subject: CanvasItem, fade_in_time: float = 0.5, stay_time:float = 1, fade_out_time: float = 0.5, skippable: bool = true) -> void:
	await fade_in(subject, fade_in_time, skippable)
	await subject.get_tree().create_timer(0.1).timeout
	await fade_out(subject, fade_out_time, stay_time, skippable)
	
	
## Move subjec to desired position (relative)
static func move_to(subject: CanvasItem, target_destination: Vector2, move_time: float = 0.5) -> void:
	var tween: Tween = subject.create_tween()
	TweenManager.call("register_tween_to_array", tween)
	tween.tween_property(subject, "position", target_destination, move_time)
	await tween.finished


## Fade in (modulate to 1) over fade_time, stay for stay_time, fade out
static func fade_in_out(subject: CanvasItem, fade_time: float = 0.5, stay_time: float = 1, ease_type: Tween.EaseType = Tween.EASE_IN_OUT, trans_type: Tween.TransitionType = Tween.TRANS_CUBIC) -> void:
	var tween: Tween = subject.create_tween()
	tween.tween_property(subject, "modulate:a", 1, fade_time).set_ease(ease_type).set_trans(trans_type)
	tween.tween_interval(stay_time)
	tween.tween_property(subject, "modulate:a", 0, fade_time).set_ease(ease_type).set_trans(trans_type)
	await tween.finished


## Fade out (modulate to 1) over fade_time, stay for stay_time, fade out
static func fade_out_in(subject: CanvasItem, fade_time: float = 0.5, stay_time: float = 1, ease_type: Tween.EaseType = Tween.EASE_IN_OUT, trans_type: Tween.TransitionType = Tween.TRANS_CUBIC) -> void:
	var tween: Tween = subject.create_tween()
	tween.tween_property(subject, "modulate:a", 0, fade_time).set_ease(ease_type).set_trans(trans_type)
	tween.tween_interval(stay_time)
	tween.tween_property(subject, "modulate:a", 1, fade_time).set_ease(ease_type).set_trans(trans_type)
	await tween.finished


## Stretch appear. Works on scale.
static func stretch_appear(subject: CanvasItem, stretch_time: float = 0.5, target_scale: Vector2 = Vector2.ONE, ease_type: Tween.EaseType = Tween.EASE_IN_OUT, trans_type: Tween.TransitionType = Tween.TRANS_CUBIC) -> void:
	if subject.get("scale") == target_scale:
		printerr("Stretch appear ineffective. {0} already at target Scale".format([subject]))
		return
		
	var tween: Tween = subject.create_tween()
	tween.tween_property(subject, "scale", target_scale, stretch_time).set_ease(ease_type).set_trans(trans_type)
	await tween.finished


## Stretch disappear. Works on scale.
static func stretch_disappear(subject: CanvasItem, stretch_time: float = 0.5, target_scale: Vector2 = Vector2.ZERO, ease_type: Tween.EaseType = Tween.EASE_IN_OUT, trans_type: Tween.TransitionType = Tween.TRANS_CUBIC) -> void:
	if subject.get("scale") == target_scale:
		printerr("Stretch disappear ineffective. {0} already at target Scale".format([subject]))
		return
		
	var tween: Tween = subject.create_tween()
	tween.tween_property(subject, "scale", target_scale, stretch_time).set_ease(ease_type).set_trans(trans_type)
	await tween.finished


## Tweens color. Works on modulate.
static func change_modulate_color(subject: CanvasItem, target_color: Color, tween_time: float = 0.5) -> void:
	var tween: Tween = subject.create_tween()
	tween.tween_property(subject, "modulate", target_color, tween_time)
	await tween.finished


## Shake subject. Set intensity and loop times, else default is loop indefinitely.
static func shake(subject: CanvasItem, intensity: float = 1, shake_speed: float = 0.05, loop_times: int = 0) -> void:
	var shake_rotation: float = 5 * intensity
	var shake_displacement: float = 2 * intensity
	
	var tween: Tween = subject.create_tween().set_parallel(true).set_loops(loop_times)
	tween.tween_property(subject, "rotation_degrees", shake_rotation, shake_speed)
	tween.tween_property(subject, "global_position", subject.get("global_position") - Vector2(shake_displacement, 0), shake_speed)
	tween.chain().tween_property(subject, "rotation_degrees", 0, shake_speed)
	tween.tween_property(subject, "global_position", subject.get("global_position"), shake_speed)
	tween.chain().tween_property(subject, "rotation_degrees", -shake_rotation, shake_speed)
	tween.tween_property(subject, "global_position", subject.get("global_position") - Vector2(-shake_displacement, 0), shake_speed)
	tween.chain().tween_property(subject, "rotation_degrees", 0, shake_speed)
	tween.tween_property(subject, "global_position", subject.get("global_position"), shake_speed)
