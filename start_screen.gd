extends Control

@onready var audio_stream : AudioStreamPlayer = %AudioStreamPlayer

func _on_button_pressed() -> void:
	visible = false
	World.game_on = true

func _on_h_slider_value_changed(value: float) -> void:
	var vol = linear_to_db(value/100)
	audio_stream.volume_db = vol
