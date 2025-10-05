extends Node

signal item_picked
signal game_over
signal new_high_score

var points : float = 0
var current_timer : float = 10
var global_timer : float = 0
var client_hit : float =0
const save_path : String = "user://scores.cfg"
var score_data : Array[Array] = [["Player1",0],["Player2",0],["Player3",0]]
var config : ConfigFile
var final_score : float

func _ready() -> void:
	_load_save()

func add_item(point_value : float, time_value : float)->void:
	points += point_value
	current_timer += time_value
	item_picked.emit()

func _process(delta: float) -> void:
	current_timer -= delta
	global_timer += delta
	if current_timer <= 0:
		game_over.emit()
	
func replay()->void:
	points = 0
	current_timer = 5
	global_timer  = 0
	client_hit = 0
	final_score = 0
	get_tree().reload_current_scene()
	get_tree().paused = false
	
func _load_save()->void:
	config = ConfigFile.new()
	var err = config.load(save_path)
	if err != OK:
		_create_save()
		return
	var i=0
	for player in config.get_sections():
		var player_name = config.get_value(player, "player_name", ("Player" + String.num(i)))
		var player_score = config.get_value(player, "player_score",0)
		score_data[i][0]= player_name
		print(player_name)
		score_data[i][1]= player_score
		print(player_score)
		i+=1
		
func calculate_score()->float:
	final_score = global_timer*(points+client_hit)
	for i in score_data.size():
		print("player ",i , " saved score :",score_data[i][1])
		print("final score : ",final_score)
		if score_data[i][1] < final_score:
			_new_high_score(i,final_score)
			new_high_score.emit(i,final_score)
			return final_score
	return final_score
			
func _new_high_score(index,score)->void:
	print("new high score!")
	var section : String = "Player" + String.num(index)
	config.set_value(section, "best_score", score)
	print(section, " new score : ", score)
	config.save(save_path)

func new_name(index,player_name)->void:
	var section : String = "Player" + String.num(index)
	config.set_value(section, "player_name", player_name)
	config.save(save_path)
	print(section, " new name : ", player_name)
	
func _get_score(index:int)->Array:
	return score_data[index]
	
func _create_save()->void:
	for i in score_data.size():
		var section : String = "Player" + String.num(i)
		config.set_value(section, "player_name", score_data[i][0])
		config.set_value(section, "best_score", score_data[i][1])
	config.save(save_path)
