extends Area2D

@export var icon : Sprite2D

var data : Item_data :
	set(_data) : 
		data = _data
		set_texture(_data.texture)
	
func _on_body_entered(body : Node2D)->void:
	if body.is_in_group("player"):
		print("player picked item")
		World.add_item(data.point,data.time)
		queue_free()

func set_texture(_texture : Texture2D)->void:
	icon.texture = _texture
