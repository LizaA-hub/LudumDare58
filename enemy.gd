extends CharacterBody2D

signal died
signal target_reached

var can_die : bool =false
var moving : bool = true
		
@export var speed:float = 4000
var target : Node2D :
	set(_target):
		target = _target
		nav_agent.target_position = target.global_position
		
@export var nav_agent : NavigationAgent2D
@export var sprite : Sprite2D
var data : Client_data:
	set(value):
		data = value
		set_texture(value.texture)

func _ready() -> void:
	nav_agent.navigation_finished.connect(_on_target_reached)
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and can_die:
		_die()
		
func _die()->void:
	died.emit(self)
	World.client_hit += 1

func _physics_process(delta):
	if moving:
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		var new_velocity = direction * speed * delta *100
		
		nav_agent.velocity = new_velocity

func _on_target_reached() -> void:
	moving = false
	target_reached.emit(self)
	
func _on_velocity_computed(safe_velocity)->void:
	velocity = velocity.move_toward(safe_velocity, 100)
	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		can_die = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		can_die = false
		
func set_texture(_texture : Texture2D)->void:
	sprite.texture = _texture
