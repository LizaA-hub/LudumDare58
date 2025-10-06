extends CharacterBody2D

signal died
signal target_reached

var can_die : bool =false
var moving : bool = true
var is_dying : bool =false
		
@export var speed:float = 4000
var target : Node2D :
	set(_target):
		target = _target
		nav_agent.target_position = target.global_position
		
@export var nav_agent : NavigationAgent2D
@export var sprite : Sprite2D
@export var die_fx : Node2D
var data : Client_data:
	set(value):
		data = value
		set_texture(value.texture)
var player_left : bool

var audio_manager : Node
var spawner : Node2D

var spawn_cooldown : float = 0.5
var is_just_spawn : bool = true

func _ready() -> void:
	nav_agent.navigation_finished.connect(_on_target_reached)
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	audio_manager = get_tree().current_scene.get_node("AudioManager")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and can_die:
		_die()
	elif event.is_action_pressed("right_click") and can_die:
		_die()
		
func _die()->void:
	audio_manager.play_client_cry()
	moving = false
	can_die = false
	is_dying = true
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	die_fx.visible = true
	var tween:Tween = create_tween()
	var direction : Vector2 = Vector2(-0.5,-1) if player_left else Vector2(0.5,-1)
	tween.tween_property(sprite,"global_position",global_position + direction*10000,1)
	tween.parallel().tween_property(sprite,"rotation",10*PI,1)
	tween.parallel().tween_property(self,"modulate",Color.TRANSPARENT,1)
	tween.parallel().tween_property(die_fx,"modulate",Color.TRANSPARENT,1)
	await tween.finished
	died.emit(self)
	World.client_hit += 1
	
func _process(delta: float) -> void:
	spawn_cooldown -= delta
	if spawn_cooldown <= 0:
		is_just_spawn = false

func _physics_process(delta):
	if moving and World.game_on:
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		var new_velocity = direction * speed * delta *100
		
		nav_agent.velocity = new_velocity

func _on_target_reached() -> void:
	moving = false
	#print("target reached")
	#print("current position :", global_position)
	#print("target position =", target.global_position)
	target_reached.emit(self)
	
func _on_velocity_computed(safe_velocity)->void:
	velocity = velocity.move_toward(safe_velocity, 100)
	move_and_slide()
	sprite.flip_h = velocity.x<0


func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_dying : return
	if area.is_in_group("player"):
		can_die = true
		if area.global_position.x < global_position.x :
			player_left = true
		else:
			player_left = false
	if area.is_in_group("client"):
		if !is_just_spawn : return
		global_position = spawner.change_position()
		spawn_cooldown = 0.5


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		can_die = false
		
func set_texture(_texture : Texture2D)->void:
	sprite.texture = _texture
	var offset_y = _texture.get_size().y/2
	sprite.position.y = -offset_y
