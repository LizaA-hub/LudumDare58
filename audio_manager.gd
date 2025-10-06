extends Node

@onready var music_stream : AudioStreamPlayer = %music
@onready var player_stream : AudioStreamPlayer = %player_sfx
@onready var pnj_stream : AudioStreamPlayer = %pnj_sfx
@onready var ui_stream : AudioStreamPlayer = %ui_sfx
@onready var walk_stream : AudioStreamPlayer = %player_walk
@onready var timer_low : AudioStreamPlayer = %timer_low
@export var game_over_sound : AudioStream
@export var loot_tracks : Array[AudioStream]
@export var punch_tracks : Array[AudioStream]

enum TimerSoundState{OFF,FADE_IN,FADE_OUT,ON}
var timer_sound_state : TimerSoundState = TimerSoundState.OFF
var timer_sound_vol : float = 0
var variation_speed : float = 1

func _ready() -> void:
	player_stream.play()
	World.game_over.connect(_on_game_over)
	
func change_music(track : String)->void:
	music_stream["parameters/switch_to_clip"] = track

func _process(delta: float) -> void:
	if !World.game_on : return
	var game_timer : float = World.current_timer
	if game_timer > 2 :
		match timer_sound_state:
			TimerSoundState.FADE_IN:
				timer_sound_state = TimerSoundState.FADE_OUT
			TimerSoundState.FADE_OUT:
				timer_sound_vol -= variation_speed*delta
				if timer_sound_vol <= 0:
					timer_sound_vol = 0
					timer_low.stop()
					timer_sound_state = TimerSoundState.OFF
			TimerSoundState.ON:
				timer_sound_state = TimerSoundState.FADE_OUT
	if game_timer <= 2 :
		match timer_sound_state:
			TimerSoundState.FADE_IN:
				timer_sound_vol += variation_speed*delta
				if timer_sound_vol >= 1:
					timer_sound_vol = 1
					timer_sound_state = TimerSoundState.ON
			TimerSoundState.FADE_OUT:
				timer_sound_state = TimerSoundState.FADE_IN
			TimerSoundState.OFF:
				timer_sound_state = TimerSoundState.FADE_IN
				timer_low.play()
				
	timer_low.volume_linear = timer_sound_vol

func play_game_over()->void:
	_play_player_sfx(game_over_sound)
	
func _play_player_sfx(track : AudioStream)->void:
	var playback = player_stream.get_stream_playback()
	playback.play_stream(track, 0, 1, 1, 0, "Master")
	
func play_loot_sound()->void:
	_play_player_sfx(loot_tracks.pick_random())

func play_punch_sound()->void:
	_play_player_sfx(punch_tracks.pick_random())
	
func play_client_cry()->void:
	pnj_stream.play()
	
func play_ui_sfx()->void:
	ui_stream.play()
	
func toggle_walk_sound(value:bool)->void:
	if walk_stream.playing == value : return
	if value:
		walk_stream.play()
	else:
		walk_stream.stop()
		
func _on_game_over()->void:
	walk_stream.stop()
	timer_low.stop()
	timer_sound_vol = 0
	
