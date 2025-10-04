extends Area2D

var player_in : bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if player_in : return
		player_in = true
		print("payer in area")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in = false
		print("payer out area")
