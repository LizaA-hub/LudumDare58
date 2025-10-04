extends Control

@export var points_label : Label
@export var timer_label : Label
@export var global_timer_label : Label
@export var timer_initial_value : float = 5

@onready var game_over_screen : Control = %game_over_screen

var current_timer : float
var global_timer : float
var current_point : float

func _ready() -> void:
	current_timer = timer_initial_value
	timer_label.text = "Timer: " + String.num(timer_initial_value)
	World.item_picked.connect(_on_item_picked)
	
func _process(delta: float) -> void:
	current_timer -= delta
	global_timer += delta
	if current_timer <= 0:
		_game_over()
	_update_timers()
	
	
func _update_timers()->void:
	timer_label.text = "Timer: " + String.num(current_timer)
	global_timer_label.text = "Global Timer :" + String.num(global_timer)
	
func _game_over()->void:
	game_over_screen.show_screen()
	
func _on_item_picked(point : float, time:float)->void:
	current_point += point
	points_label.text = "Points : " + String.num(current_point)
	current_timer += time
