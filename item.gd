extends Area2D

@export var icon : Sprite2D
var player_in : bool = false
signal picked


var data : Item_data :
	set(_data) : 
		data = _data
		set_texture(_data.texture)
		
var audio_manager : Node

func _ready() -> void:
	audio_manager = get_tree().current_scene.get_node("AudioManager")
	
func set_texture(_texture : Texture2D)->void:
	icon.texture = _texture
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("item"):
		#print("collide with item!")
		picked.emit(self)
	if area.is_in_group("player"):
		if player_in : return
		audio_manager.play_loot_sound()
		player_in = true
		World.add_item(data.point,data.time)
		picked.emit(self)
