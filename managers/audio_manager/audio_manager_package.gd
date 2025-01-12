class_name AudioManagerClass
extends Node
## Submodule of [UtilsPackageClass]. Provides autoloaded audio playing support for both SFX and Music.

## Organization layer where SFX [AudioStreamPlayer2D] are added
@export var sfx_layer: Node
## Organization layer where Looping audio (e.g. music) [AudioStreamPlayer2D] are added
@export var music_layer: Node

const SFX_BUTTON_CLICK = preload("res://assets/Audio/SFX/sfxButtonClick.mp3")
const START_GAME = preload("res://assets/Audio/SFX/Start game.ogg")

const OPEN_MENU_001 = preload("res://assets/Audio/SFX/open menu-001.ogg")
const MENU_SELECT = preload("res://assets/Audio/SFX/menu select.ogg")
const MENU_EXIT = preload("res://assets/Audio/SFX/menu exit.ogg")

const ENEMY_GUNSHOT_001 = preload("res://assets/Audio/SFX/enemy gunshot-001.ogg")
const ENEMY_GUNSHOT_002 = preload("res://assets/Audio/SFX/enemy gunshot-002.ogg")
const ENEMY_GUNSHOT_003 = preload("res://assets/Audio/SFX/enemy gunshot-003.ogg")
var enemy_gunshot_sounds: Array[AudioStream] = [ENEMY_GUNSHOT_001, ENEMY_GUNSHOT_002, ENEMY_GUNSHOT_003]

const PLAYER_GUNSHOT_001 = preload("res://assets/Audio/SFX/player gunshot-001.ogg")
const PLAYER_GUNSHOT_002 = preload("res://assets/Audio/SFX/player gunshot-002.ogg")
const PLAYER_GUNSHOT_003 = preload("res://assets/Audio/SFX/player gunshot-003.ogg")
const PLAYER_GUNSHOT_004 = preload("res://assets/Audio/SFX/player gunshot-004.ogg")
var player_gunshot_sounds: Array[AudioStream] = [PLAYER_GUNSHOT_001, PLAYER_GUNSHOT_002, PLAYER_GUNSHOT_003, PLAYER_GUNSHOT_004]

const ENEMY_HURT_001 = preload("res://assets/Audio/SFX/enemy hurt-001.ogg")
const ENEMY_HURT_002 = preload("res://assets/Audio/SFX/enemy hurt-002.ogg")
const ENEMY_HURT_003 = preload("res://assets/Audio/SFX/enemy hurt-003.ogg")
var enemy_hurt_sounds: Array[AudioStream] = [ENEMY_HURT_001, ENEMY_HURT_002, ENEMY_HURT_003]

const takedown_finisher1 = preload("res://assets/Audio/SFX/takedown kill-001.ogg")
const takedown_finisher2 = preload("res://assets/Audio/SFX/takedown kill-002.ogg")
var enemy_takedown_death_sounds: Array[AudioStream] = [takedown_finisher1, takedown_finisher2]

const takedown_choke1 = preload("res://assets/Audio/SFX/takedown choke-001.ogg")
const takedown_choke2 = preload("res://assets/Audio/SFX/takedown choke-002.ogg")
const ENEMY_DIE_SHOT = preload("res://assets/Audio/SFX/enemy die shot.ogg")

const PLAYER_HURT_001 = preload("res://assets/Audio/SFX/player hurt-001.ogg")
const PLAYER_HURT_002 = preload("res://assets/Audio/SFX/player hurt-002.ogg")
var player_hurt_sounds: Array[AudioStream] = [PLAYER_HURT_001, PLAYER_HURT_002]
const PLAYER_DIE = preload("res://assets/Audio/SFX/player die.ogg")

const TITLE_SCREEN = preload("res://assets/Audio/Music/title screen.ogg")
const TEXT_SCROLL_001 = preload("res://assets/Audio/SFX/text scroll-001.ogg")

const NIGHT_VISION_GOGGLES = preload("res://assets/Audio/SFX/night vision goggles.ogg")
const SNEAK_DAY_MAIN_LAYER = preload("res://assets/Audio/Music/adaptive sneaking theme/sneak day main layer.ogg")
const SNEAK_DAY_ALERT_LAYER = preload("res://assets/Audio/Music/adaptive sneaking theme/sneak day alert layer.ogg")
const SNEAK_NIGHT_MAIN_LAYER = preload("res://assets/Audio/Music/adaptive sneaking theme/Sneak night main layer.ogg")
const SNEAK_NIGHT_ALERT_LAYER = preload("res://assets/Audio/Music/adaptive sneaking theme/sneak night alert layer.ogg")
const VICTORY_OR_GAME_OVER_1 = preload("res://assets/Audio/Music/victory or game over 1.ogg")

const PLAYER_RELOAD = preload("res://assets/Audio/SFX/player reload.ogg")
const PLAYER_ROLL = preload("res://assets/Audio/SFX/player roll.ogg")


## Plays an SFX. Creates a [AudioStreamPlayer2D] instance, assigns provided [AudioStream], auto queue_free() when finished.
func play_sfx(sfx_stream: AudioStream, stream_name: String) -> void:
	var sfx_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sfx_player.bus = &"SFX"
	sfx_player.stream = sfx_stream
	sfx_player.name = stream_name
	sfx_player.finished.connect(queue_free_audio_stream.bind(sfx_player))
	sfx_layer.add_child(sfx_player)
	sfx_player.play()


## Creates and returns an SFX_player that can be queued free separately. Useful to be referenced another Node.
func create_and_return_sfx_player(sfx_stream: AudioStream, sfx_player_name: String) -> AudioStreamPlayer2D:
	var sfx_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sfx_player.bus = &"SFX"
	sfx_player.stream = sfx_stream
	sfx_player.name = sfx_player_name
	sfx_player.finished.connect(queue_free_audio_stream.bind(sfx_player))
	sfx_layer.add_child(sfx_player)
	sfx_player.play()
	return sfx_player


## Plays Music. Creates a [AudioStreamPlayer2D] instance, assigns provided [AudioStream].
func play_music(music_stream: AudioStream, stream_name: String, starting_db: float = 0) -> void:
	var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
	music_player.bus = &"Music"
	music_player.stream = music_stream
	music_player.name = stream_name
	music_layer.add_child(music_player)
	music_player.volume_db = starting_db
	music_player.play()
	

## Queues free provided [AudioStreamPlayer2D]
func queue_free_audio_stream(audio_stream_player: AudioStreamPlayer2D) -> void:
	audio_stream_player.queue_free()


## Dims and kill selected stream, after set amount of time.
func dim_and_kill_stream(selector: Variant, dim_duration: float = 1) -> void:
	var audio_stream_player: AudioStreamPlayer
	
	if selector is AudioStreamPlayer:
		audio_stream_player = selector
	
	if selector is String:
		var node_path: NodePath = selector as NodePath
		
		if ! music_layer.has_node(node_path):
			return
		
		audio_stream_player = music_layer.get_node(node_path)
	
	var tween: Tween = create_tween()
	tween.tween_property(audio_stream_player, "volume_db", -15, dim_duration)
	tween.tween_callback(audio_stream_player.queue_free)
	

## Kills all stream in both SFX and Looping layer
func kill_all_stream() -> void:
	for layer: Node in [sfx_layer, music_layer]:
		for child in layer.get_children():
			child.queue_free()


## Dim and kill all streams
func dim_and_kill_all_streams() -> void:
	for layer: Node in [sfx_layer, music_layer]:
		for child in layer.get_children():
			var tween: Tween = create_tween()
			tween.tween_property(child, "volume_db", -15, 1)
			tween.tween_callback(child.queue_free)


func _ready() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(0.8))
	AudioServer.set_bus_volume_db(1, linear_to_db(0.5))
	AudioServer.set_bus_volume_db(2, linear_to_db(1))
