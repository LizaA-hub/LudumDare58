extends Node

signal item_picked(new_point : float, time_gain : float)
var points : float = 0

func add_item(point_value : float, time_value : float)->void:
	points += point_value
	item_picked.emit(points, time_value)
