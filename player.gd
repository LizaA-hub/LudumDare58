extends CharacterBody2D

@export var speed : float = 100
@export var shelves_layer : TileMapLayer
@onready var normal_sprite : Sprite2D = %normal_sprite
@onready var combat_sprite : Sprite2D = %combat_sprite
@onready var audio_manager : Node = %AudioManager

var click_position : Vector2
var target_position : Vector2

var walk_sound_timer : Timer
var can_play_sound : bool = true
var can_move : bool = true

var initial_position : Vector2

func _ready() -> void:
	World.replay_game.connect(_on_replay)
	walk_sound_timer = Timer.new()
	add_child(walk_sound_timer)
	walk_sound_timer.timeout.connect(_on_walk_sound_timer_timeout)
	initial_position = global_position
	
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
			
		if can_move:
			move_and_slide()
		normal_sprite.flip_h = true if velocity.x<0 else false
		combat_sprite.scale.x = -1 if velocity.x<0 else 1
		
		# Mise à jour du Z-index basé sur la position Y et les étagères
		update_z_index_with_shelves()
		
		if velocity != Vector2.ZERO:
			audio_manager.toggle_walk_sound(true)
		else:
			audio_manager.toggle_walk_sound(false)
			
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("right_click"):
			audio_manager.play_punch_sound()

func update_z_index_with_shelves():
	if shelves_layer == null:
		z_index = 1
		return
	
	# Récupère la position de la tuile sur laquelle se trouve le joueur
	var tile_pos : Vector2i = shelves_layer.local_to_map(global_position)
	
	# Vérifie les étagères dans un rayon autour du joueur
	for x in range(-1, 2):
		for y in range(-1, 2):
			var check_pos : Vector2i = tile_pos + Vector2i(x, y)
			var tile_data = shelves_layer.get_cell_tile_data(check_pos)
			
			if tile_data != null:
				# Il y a une étagère à cette position
				var shelf_world_pos : Vector2 = shelves_layer.map_to_local(check_pos)
				
				# Ajoute un offset pour compenser la hauteur de l'étagère
				var shelf_bottom_y = shelf_world_pos.y + 32 # Valeur à modifier en fonction de l'offset désiré
				
				# Le joueur passe derrière si l'étagère est en dessous de lui (Y plus grand)
				if shelf_bottom_y < global_position.y:
					z_index = -1
					return

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y,(cartesian.x + cartesian.y)/2)
	
func _on_replay()->void:
	position = initial_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		World.pause(World.game_on)
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("right_click"):
		normal_sprite.visible = false
		combat_sprite.visible = true
		can_move = false
	elif event.is_action_released("ui_accept")or event.is_action_released("right_click"):
		normal_sprite.visible = true
		combat_sprite.visible = false
		can_move = true

func _on_walk_sound_timer_timeout()->void:
	can_play_sound = true
