extends TileMapLayer

@onready var shelfs:TileMapLayer  = %shelfs

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in shelfs.get_used_cells_by_id(0):
		return true
	elif coords in shelfs.get_used_cells_by_id(1):
		return true
	return false
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in shelfs.get_used_cells_by_id(0):
		tile_data.set_navigation_polygon(0,null)
		#tile_data.set_navigation_polygon(1,null)
	elif coords in shelfs.get_used_cells_by_id(1):
		tile_data.set_navigation_polygon(0,null)
		#tile_data.set_navigation_polygon(1,null)
