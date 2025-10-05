extends Control

@export var points_label : Label
@export var timer_label : Label
@export var global_timer_label : Label

func _ready() -> void:
	World.item_picked.connect(_on_item_picked)
	
func _process(_delta: float) -> void:
	timer_label.text = "Timer: " + String.num(World.current_timer,1)
	global_timer_label.text = "Global Timer :" + String.num(World.global_timer,1)
	
func _on_item_picked()->void:
	points_label.text = "Points : " + String.num(World.points,0)
