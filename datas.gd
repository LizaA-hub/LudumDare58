extends Control

@export var points_label : Label
@export var timer_label : Label
@export var global_timer_label : Label

func _ready() -> void:
	World.item_picked.connect(_on_item_picked)
	
func _process(_delta: float) -> void:
	var timer : float = World.current_timer
	var m_seconds : int = int(timer*60)%60
	var seconds: int = int(timer)%60
	var minutes : int = int(timer/60)%60
	timer_label.text = "Timer : %d:%02d:%02d"%[minutes,seconds,m_seconds]
	
	var time_elapsed : float = World.global_timer
	m_seconds  = int(time_elapsed*60)%60
	seconds =int(time_elapsed)%60
	minutes  = int(time_elapsed/60)%60
	global_timer_label.text = "Global Timer : %d:%02d:%02d"%[minutes,seconds,m_seconds]
	
func _on_item_picked()->void:
	points_label.text = "Points : " + String.num(World.points,0)
