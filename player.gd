extends CharacterBody2D

@export var speed : float = 100

func _ready() -> void:
	World.replay_game.connect(_on_replay)
	
func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = cartesian_to_isometric(input_direction) * speed

func _physics_process(_delta):
	if World.game_on:
		get_input()
		move_and_slide()

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y,(cartesian.x + cartesian.y)/2)
	
func _on_replay()->void:
	position = Vector2.ZERO
