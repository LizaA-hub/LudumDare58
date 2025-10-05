extends ColorRect

func _ready() -> void:
	World.paused.connect(_on_pause)

func _on_button_pressed() -> void:
	World.pause(false)
	visible = false

func _on_pause()->void:
	visible = true
