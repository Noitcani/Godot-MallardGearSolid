class_name TweenManagerClass
extends Node

var skippabale_tween_array: Array[Tween]

func _skip_oldest_tween_in_queue() -> void:
	if skippabale_tween_array.is_empty(): return
	var safe_array: Array[Tween] = skippabale_tween_array.duplicate()
	var oldest_tween: Tween = safe_array.pop_back()
	oldest_tween.custom_step(9999)
	skippabale_tween_array = safe_array
	

func _on_tween_finished(finished_tween: Tween) -> void:
	var safe_array: Array[Tween] = skippabale_tween_array.duplicate()
	safe_array.erase(finished_tween)
	finished_tween.kill()
	skippabale_tween_array = safe_array


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_mouse_button: InputEventMouseButton = event
		if event_mouse_button.button_index == MOUSE_BUTTON_LEFT and event_mouse_button.is_pressed():
			_skip_oldest_tween_in_queue()
			get_viewport().set_input_as_handled()
			return
		
	elif event.is_action_pressed("ui_accept"):
		_skip_oldest_tween_in_queue()
		get_viewport().set_input_as_handled()
		return


func register_tween_to_array(new_tween: Tween) -> void:
	skippabale_tween_array.push_front(new_tween)
	new_tween.finished.connect(_on_tween_finished.bind(new_tween))

