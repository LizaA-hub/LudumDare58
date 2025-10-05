extends Node2D

var spawns : Array[Node]
@export var items : Array[Item_data]
@export var max_distance : float = 1000
@export var item_max_nb : int = 8

var item_prefab : PackedScene = preload("res://item.tscn")

@onready var player : CharacterBody2D = %CharacterBody2D
#@onready var enviro : Node2D = %enviro
@onready var screen_min_y : Marker2D = %MarkerY
@onready var screen_min_x : Marker2D = %MarkerX

var instantiated_items : Array[Area2D]
var while_safety : int =0
var busy:bool = false

func _ready() -> void:
	_populate_spawns()
	World.replay_game.connect(_on_replay)
	
func _populate_spawns()->void:
	spawns = get_children()
	_spawn_item()

func _spawn_item()->void:
	##pick a random shelf outside the screen
	var spawn : Node2D = spawns.pick_random()
	#var spawn_pos = get_spawn_position(spawn)
	#while spawn_pos == null:
		#spawn = spawns.pick_random()
		#while_safety +=1
		#print("loop count : ",while_safety)
		#assert(while_safety < 1000,"infinite loop!")
	#while_safety = 0
	while !outside_screen(spawn.position):
		#spawn_pos = get_spawn_position(spawn)
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
	spawn.call_deferred("add_child",new_item,false)
	#new_item.position = spawn.position
	
	instantiated_items.append(new_item)
	if instantiated_items.size() < item_max_nb:
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
	if busy : return
	busy = true
	instantiated_items.erase(item)
	item.queue_free()
	if instantiated_items.size() < item_max_nb :
		_spawn_item()
	call_deferred("_end_task")
		
func _end_task()->void:
	busy = false
	
func outside_screen(spawn_pos : Vector2)->bool:
	var y_good : bool = spawn_pos.y < screen_min_y.position.y or spawn_pos.y > player.position.y-screen_min_y.position.y
	#print("screen max y = ",player.position.y-screen_min_y.position.y)
	var x_good : bool = spawn_pos.x < screen_min_x.position.x or spawn_pos.x > player.position.x-screen_min_x.position.x
	#print("screen max x = ",player.position.x-screen_min_x.position.x)
	#var not_too_far : bool = spawn_pos.distance_to(player.global_position) < max_distance
	#print("pos = ",spawn_pos)
	return y_good or x_good #and not_too_far
	
func _on_replay()->void:
	for item in instantiated_items :
		item.queue_free()
	instantiated_items.clear()
	while_safety =0
	busy= false
	_spawn_item()
	
