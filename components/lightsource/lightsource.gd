class_name Lightsource
extends PointLight2D

@onready var detection_area: Area2D = %DetectionArea

var lightsource_active: bool
var player_in_light: Player
var light_hitting_player: bool


func _on_body_entered(other_body: Node2D) -> void:
	if other_body is Player:
		player_in_light = other_body


func _on_body_exited(other_body: Node2D) -> void:
	if other_body is Player:
		player_in_light = null


func _cast_rays_to_player() -> void:
	var space_state := get_world_2d().direct_space_state
	var top_left_point_of_player: Vector2 = player_in_light.global_position - (player_in_light.collision_shape_shape.size / 2.5)
	var top_right_point_of_player: Vector2 = Vector2( player_in_light.global_position.x + (player_in_light.collision_shape_shape.size.x / 2.5), player_in_light.global_position.y - (player_in_light.collision_shape_shape.size.y / 2.5) )
	var bottom_left_point_of_player: Vector2 = Vector2( player_in_light.global_position.x - (player_in_light.collision_shape_shape.size.x / 2.5), player_in_light.global_position.y + (player_in_light.collision_shape_shape.size.y / 2.5) )
	var bottom_right_point_of_player: Vector2 = player_in_light.global_position + (player_in_light.collision_shape_shape.size / 2.5)
	
	var array_of_points_to_cast_to := [top_left_point_of_player, top_right_point_of_player, bottom_left_point_of_player, bottom_right_point_of_player]
	
	for point: Vector2 in array_of_points_to_cast_to:
		var query := PhysicsRayQueryParameters2D.create(global_position, point)
		query.collision_mask = 0b00000000_00000000_00000000_00001011
		query.exclude = [self]
		var result := space_state.intersect_ray(query)
		if result and result["collider"] == player_in_light:
			player_in_light.hp_component.take_damage(1)
			light_hitting_player = true
			return
		
		light_hitting_player = false


func _physics_process(_delta: float) -> void:
	light_hitting_player = false
	if lightsource_active:
		if player_in_light:
			_cast_rays_to_player()


func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)


func enable(is_on: bool) -> void:
	detection_area.monitorable = is_on
	detection_area.monitoring = is_on
	visible = is_on
	lightsource_active = is_on
