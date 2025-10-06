extends Node2D

var spawns : Array[Node]
@export var items : Array[Item_data]
@export var item_min_nb : int = 3

var item_prefab : PackedScene = preload("res://item.tscn")

@onready var player : CharacterBody2D = %player

var instantiated_items : Array[Area2D]
var while_safety : int =0
var busy:bool = false
var increase_counter : int = 0
var item_nb_target : int = 12

func _ready() -> void:
	_populate_spawns()
	World.replay_game.connect(_on_replay)
	
func _populate_spawns()->void:
	spawns = get_children()
	_spawn_item()

func _spawn_item()->void:
	##pick a random shelf outside the screen
	var spawn : Node2D = spawns.pick_random()
	while !outside_screen(spawn.position):
		spawn = spawns.pick_random()
		while_safety +=1
		print("loop count : ",while_safety)
		assert(while_safety < 1000,"infinite loop!")
	while_safety = 0
	
	##pick a random item
	var item_list : Array[Item_data]
	for item in items:
		for j in item.multiplier:
			item_list.append(item)
			
	var item_data : Item_data = item_list.pick_random()
	var new_item : Area2D = item_prefab.instantiate()
	new_item.data = item_data
	new_item.picked.connect(_on_item_picked)
	new_item.spawner = self
	spawn.call_deferred("add_child",new_item,false)
	
	instantiated_items.append(new_item)
	if instantiated_items.size() < item_nb_target:
		_spawn_item()


func get_spawn_position(spawn : Node2D):
	var collision : CollisionShape2D = spawn.get_child(0)
	var right_bottom_vect : Vector2 = spawn.position + collision.shape.get_rect().size/2 - Vector2(80,80)
	#print("right bottom : ", right_bottom_vect)
	var left_up_vect : Vector2 = spawn.position - collision.shape.get_rect().size/2 + Vector2(80,80)
	#print("left up : ", left_up_vect)
	if !outside_screen(right_bottom_vect) and !outside_screen(left_up_vect):
		return null
	var random_pos : Vector2 = Vector2(randf_range(left_up_vect.x,right_bottom_vect.x),randf_range(left_up_vect.y,right_bottom_vect.y))
	#print("spawn pos : ", random_pos)
	return random_pos

func _on_item_picked(item : Area2D)->void:
	instantiated_items.erase(item)
	item.queue_free()
	increase_counter +=1
	if increase_counter==3:
		increase_counter = 0
		item_nb_target -= 1
		
	if instantiated_items.size() >= item_nb_target:return
	_spawn_item()

	
func outside_screen(spawn_pos : Vector2)->bool:
	var distance_to_player : Vector2 = spawn_pos - player.global_position
	var y_good : bool = abs(distance_to_player.y) < player.camera_bound.y or abs(distance_to_player.y) > player.camera_bound.y
	var x_good : bool =abs(distance_to_player.x) < player.camera_bound.x or abs(distance_to_player.x) > player.camera_bound.x
	return y_good or x_good 
	
func _on_replay()->void:
	for item in instantiated_items :
		item.queue_free()
	instantiated_items.clear()
	while_safety =0
	busy= false
	increase_counter = 0
	item_nb_target = 12
	_spawn_item()
	
func change_position()->Vector2:
	var spawn : Node2D = spawns.pick_random()
	while !outside_screen(spawn.position):
		spawn = spawns.pick_random()
		while_safety +=1
		#print("loop count : ",while_safety)
		assert(while_safety < 1000,"infinite loop!")
	while_safety = 0
	return spawn.global_position
