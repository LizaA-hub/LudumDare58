extends CharacterBody2D

@export var speed : float = 100

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var input_horizontal = Input.get_axis("ui_left","ui_right")
	#var input_vertical = Input.get_axis("ui_up","ui_down")
	#var input_direction = Vector2(-input_vertical+input_horizontal,input_vertical+input_horizontal)
	#var rotated_direction = input_direction.rotated(1.1)
	velocity = cartesian_to_isometric(input_direction) * speed

func _physics_process(_delta):
	get_input()
	move_and_slide()

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y,(cartesian.x + cartesian.y)/2)
