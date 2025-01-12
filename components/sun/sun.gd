class_name Sun
extends Sprite2D

@export var rotation_speed: float = 1.5
@onready var play_scene: PlayScene = get_tree().get_first_node_in_group("play_scene")
@onready var sun_lightsource: Lightsource = %SunLightsource

@onready var signals_manager: SignalsManagerClass = SignalsManager


func _physics_process(delta: float) -> void:
	if sun_lightsource.visible:
		rotation_degrees += rotation_speed * delta


func _on_new_day(_day_count: int)  -> void:
	sun_lightsource.enable(true)


func _on_new_night() -> void:
	sun_lightsource.enable(false)


func _ready() -> void:
	signals_manager.new_day.connect(_on_new_day)
	signals_manager.new_night.connect(_on_new_night)
