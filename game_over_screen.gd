extends Control

@onready var total_time_label : Label = %total_time
@onready var points_label : Label = %points
@onready var client_label : Label = %client
@onready var score_label : Label = %score
@onready var player_name_01 : Label = %player_name_01
@onready var player_name_02 : Label = %player_name_02
@onready var player_name_03 : Label = %player_name_03
@onready var player_score_01 : Label = %player_score_01
@onready var player_score_02 : Label = %player_score_02
@onready var player_score_03 : Label = %player_score_03
@onready var replay_button : Button = %replay_button
@onready var new_score_label  : Label = %new_score
@onready var new_score_panel : PanelContainer = %new_score_panel
@onready var entered_name : LineEdit = %name_slot
@onready var new_score_position : Label = %new_score_position

var new_score_index : int

func _ready() -> void:
	World.game_over.connect(_show_screen)
	World.new_high_score.connect(_on_new_high_score)
	
func _show_screen()->void:
	get_tree().paused = true
	total_time_label.text = String.num(World.global_timer)
	points_label.text = String.num(World.points)
	client_label.text = String.num(World.client_hit)
	score_label.text = String.num(World.calculate_score())
	update_scores()
	visible = true
	
func _on_button_pressed() -> void:
	World.replay()
	
func _on_new_high_score(index,score)->void:
	new_score_index = index
	new_score_label.text = String.num(score)
	new_score_position.text = "#" + String.num(index)
	new_score_panel.visible = true


func _on_validate_button_pressed() -> void:
	World.new_name(new_score_index,entered_name.text)
	update_scores()
	new_score_panel.visible = false
	
func update_scores()->void:
	player_name_01.text = World.score_data[0][0]
	player_name_02.text = World.score_data[1][0]
	player_name_03.text = World.score_data[2][0]
	player_score_01.text= String.num(World.score_data[0][1])
	player_score_02.text= String.num(World.score_data[1][1])
	player_score_03.text= String.num(World.score_data[2][1])
