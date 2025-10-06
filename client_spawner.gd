extends Node2D

var spawns : Array[Node]
@export var clients : Array[Client_data]
@export var client_max_nb : int = 100

var client_prefab : PackedScene = preload("res://enemy.tscn")

@onready var player : CharacterBody2D = %player
@onready var screen_min_y : Marker2D = %MarkerY
@onready var screen_min_x : Marker2D = %MarkerX

var instantiated_enemies : Array[CharacterBody2D]
var while_safety : int =0
var busy:bool = false
var nb_increase : Array = [1,2]
var increase_index: int = 0
var increase_counter : int = 0
var client_nb_target : int = 3

func _ready() -> void:
	_populate_spawns()
	World.item_picked.connect(_on_item_picked)
	
func _populate_spawns()->void:
	spawns = get_children()
	_spawn_enemy()

func _spawn_enemy()->void:
	##pick a random spawn outside the screen
	var spawn : Node2D = spawns.pick_random()
	while !outside_screen(spawn.position):
		spawn = spawns.pick_random()
		while_safety +=1
		print("loop count : ",while_safety)
		assert(while_safety < 1000,"infinite loop!")
	while_safety = 0
	
	##pick a random client
	var client_data : Client_data = clients.pick_random()
	var new_client : CharacterBody2D = client_prefab.instantiate()
	new_client.data = client_data
	new_client.died.connect(_on_client_died)
	new_client.target_reached.connect(_on_target_reached)
	new_client.spawner = self
	spawn.call_deferred("add_child",new_client,false)
	_on_target_reached(new_client)
	
	instantiated_enemies.append(new_client)
	if instantiated_enemies.size() < client_nb_target:
		_spawn_enemy()


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

func _on_client_died(client : CharacterBody2D)->void:
	#if busy : return
	busy = true
	instantiated_enemies.erase(client)
	client.queue_free()
	if instantiated_enemies.size() < client_nb_target :
		_spawn_enemy()
	call_deferred("_end_task")
		
func _end_task()->void:
	busy = false
	
func outside_screen(spawn_pos : Vector2)->bool:
	var y_good : bool = spawn_pos.y < screen_min_y.position.y or spawn_pos.y > player.position.y-screen_min_y.position.y
	var x_good : bool = spawn_pos.x < screen_min_x.position.x or spawn_pos.x > player.position.x-screen_min_x.position.x
	return y_good or x_good
	
func _on_target_reached(client : CharacterBody2D)->void:
	var new_target:Node = spawns.pick_random()
	while new_target.position.distance_to(client.position) < 500:
		new_target = spawns.pick_random()
		while_safety +=1
		assert(while_safety < 1000,"infinite loop!")
	while_safety = 0
	client.target = new_target
	client.moving = true
	
func _on_replay()->void:
	for client in instantiated_enemies :
		client.queue_free()
	instantiated_enemies.clear()
	while_safety =0
	busy= false
	client_nb_target = 3
	increase_index=0
	_spawn_enemy()
	
func change_position()->Vector2:
	var spawn : Node2D = spawns.pick_random()
	while !outside_screen(spawn.position):
		spawn = spawns.pick_random()
		while_safety +=1
		#print("loop count : ",while_safety)
		assert(while_safety < 1000,"infinite loop!")
	while_safety = 0
	return spawn.global_position

func _on_item_picked()->void:
	if client_nb_target >= client_max_nb : return
	increase_counter += 1
	if increase_counter == 2 :
		increase_counter = 0
		if increase_index==1:
			increase_index=0
		client_nb_target += nb_increase[increase_index]
		increase_index += 1
		
