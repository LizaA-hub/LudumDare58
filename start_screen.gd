extends Control

@onready var audio_manager : Node = %AudioManager
@onready var slider : HSlider = %HSlider

func _ready() -> void:
	slider.set_value_no_signal(AudioServer.get_bus_volume_linear(0)*100)

func _on_button_pressed() -> void:
	audio_manager.play_ui_sfx()
	audio_manager.change_music("main")
	visible = false
	World.game_on = true

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0,value/100)
