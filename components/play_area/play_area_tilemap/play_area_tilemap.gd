class_name PlayAreaTilemap
extends TileMap

@onready var floor: TileMapLayer = %Floor

func _use_tile_data_runtime_update(_layer: int, coords: Vector2i) -> bool:
	if coords in get_used_cells_by_id(1):
		return true
	return false
	
	
func _tile_data_runtime_update(_layer: int, _coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)
