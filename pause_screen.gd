extends ColorRect

@onready var audio_manager : Node = %AudioManager

func _ready() -> void:
	World.paused.connect(_on_pause)

func _on_button_pressed() -> void:
	audio_manager.play_ui_sfx()
	World.pause(false)
	visible = false

func _on_pause()->void:
	audio_manager.play_ui_sfx()
	visible = true
