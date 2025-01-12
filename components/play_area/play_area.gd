class_name PlayArea
extends Node2D

@onready var play_area_tilemap: PlayAreaTilemap = %PlayAreaTilemap
@onready var enemy_spawn_points_layer: Node2D = %EnemySpawnPointsLayer


func get_random_spawn_point_pos() -> Vector2:
	var result: Vector2
	var spawn_point_array_randomed := enemy_spawn_points_layer.get_children().duplicate()
	spawn_point_array_randomed.shuffle()
	
	for spawn_point: EnemySpawnPoint in spawn_point_array_randomed:
		if spawn_point.is_active:
			result = spawn_point.global_position
			break
	return result
