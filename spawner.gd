extends Node2D

@export var spawns : Array[Node2D]
@export var items : Array[Item_data]

var item_prefab : PackedScene = preload("res://item.tscn")

func _ready() -> void:
	World.item_picked.connect(_spawn_item)
	_spawn_item(0,0)

func _spawn_item(_point:float, _value:float)->void:
	var spawn : Node2D = spawns.pick_random()
	var item_list : Array[Item_data]
	for item in items:
		for j in item.multiplier:
			item_list.append(item)
			
	var item_data : Item_data = item_list.pick_random()
	var new_item = item_prefab.instantiate()
	new_item.data = item_data
	spawn.call_deferred("add_child",new_item)
