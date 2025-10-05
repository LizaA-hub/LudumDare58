extends Area2D

@export var icon : Sprite2D
var player_in : bool = false
signal picked


var data : Item_data :
	set(_data) : 
		data = _data
		set_texture(_data.texture)
	#
#func _on_body_entered(body : Node2D)->void:
	#if body.is_in_group("player"):
		#if player_in : return
		#player_in = true
		#World.add_item(data.point,data.time)
		#picked.emit(self)

func set_texture(_texture : Texture2D)->void:
	icon.texture = _texture
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("item"):
		#print("collide with item!")
		picked.emit(self)
	if area.is_in_group("player"):
		if player_in : return
		player_in = true
		World.add_item(data.point,data.time)
		picked.emit(self)
