extends Control

@export var points_label : Label
@export var timer_label : Label
enum TimerState{RED,WHITE}
var timer_state : TimerState = TimerState.WHITE
var timer_color : Color

func _ready() -> void:
	World.item_picked.connect(_on_item_picked)
	timer_color = timer_label.label_settings.font_color
	
func _process(_delta: float) -> void:
	if !World.game_on : return
	var timer : float = World.current_timer
	var m_seconds : int = int(timer*60)%60
	var seconds: int = int(timer)%60
	var minutes : int = int(timer/60)%60
	timer_label.text = "%02d:%02d:%02d" % [minutes, seconds, m_seconds]
	
	if timer > 2 :
			match timer_state:
				TimerState.RED:
					timer_label.label_settings.font_color = timer_color
					timer_state = TimerState.WHITE
	elif timer <= 2 :
		match timer_state:
			TimerState.WHITE:
				timer_label.label_settings.font_color = Color.RED
				timer_state = TimerState.RED
	
func _on_item_picked()->void:
	points_label.text = String.num(World.points,0)
