extends CharacterBody2D

var can_die : bool =false
var moving : bool = true
@export var speed:float = 4000
@export var target : Node2D
@onready var nav_agent : NavigationAgent2D = %NavigationAgent2D

func _ready() -> void:
	nav_agent.navigation_finished.connect(_on_target_reached)
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.target_position = target.global_position
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_die = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_die = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and can_die:
		_die()
		
func _die()->void:
	queue_free()

func _physics_process(delta):
	if moving:
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		var new_velocity = direction * speed * delta
		
		nav_agent.velocity = new_velocity

func _on_target_reached() -> void:
	moving = false
	
func _on_velocity_computed(safe_velocity)->void:
	velocity = velocity.move_toward(safe_velocity, 100)
	move_and_slide()
