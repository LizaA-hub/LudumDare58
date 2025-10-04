extends Control

func _ready() -> void:
	World.game_over.connect(show_screen)
	
func show_screen()->void:
	get_tree().paused = true
	visible = true
	
func _on_button_pressed() -> void:
	World.replay()
