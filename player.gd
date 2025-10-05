extends CharacterBody2D

@export var speed : float = 100
@onready var normal_sprite : Sprite2D = %normal_sprite
@onready var combat_sprite : Sprite2D = %combat_sprite

var click_position : Vector2
var target_position : Vector2

func _ready() -> void:
	World.replay_game.connect(_on_replay)
	
func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity =cartesian_to_isometric(input_direction) * speed

func _physics_process(_delta):
	if World.game_on:
		get_input()
		if Input.is_action_pressed("left_click"):
			click_position = get_global_mouse_position()
			if position.distance_to(click_position)>500:
				target_position = (click_position - position).normalized()
				velocity = target_position * speed
			
		move_and_slide()
		normal_sprite.flip_h = true if velocity.x<0 else false
		combat_sprite.scale.x = -1 if velocity.x<0 else 1

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y,(cartesian.x + cartesian.y)/2)
	
func _on_replay()->void:
	position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		World.pause(World.game_on)
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("right_click"):
		normal_sprite.visible = false
		combat_sprite.visible = true
	elif event.is_action_released("ui_accept")or event.is_action_released("right_click"):
		normal_sprite.visible = true
		combat_sprite.visible = false
