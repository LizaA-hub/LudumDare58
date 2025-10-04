extends Node

signal item_picked
signal game_over
var points : float = 0
var current_timer : float = 5
var global_timer : float = 0

func add_item(point_value : float, time_value : float)->void:
	points += point_value
	current_timer += time_value
	item_picked.emit()

func _process(delta: float) -> void:
	#current_timer -= delta
	global_timer += delta
	if current_timer <= 0:
		game_over.emit()
	
func replay()->void:
	points = 0
	current_timer = 5
	global_timer  = 0
	get_tree().reload_current_scene()
	get_tree().paused = false
