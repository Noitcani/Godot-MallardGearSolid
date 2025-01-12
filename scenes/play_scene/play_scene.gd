class_name PlayScene
extends Node2D

@export var day_darkness_dim: float = 0.3
@export var night_darkness_dim: float = 0.8

@onready var enemies_manager: EnemiesManager = %EnemiesManager
@onready var game_progression_manager: GameProgressionManager = %GameProgressionManager
@onready var upgrades_manager: UpgradesManager = %UpgradesManager
@onready var hud: HUD = %HUD

@onready var pause_menu: CanvasLayer = %Pause_menu
@onready var player: Player = %Player
@onready var play_area: PlayArea = %PlayArea
@onready var enemies_layer: Node2D = %EnemiesLayer
@onready var enemies_death_animation_layer: Node2D = %EnemiesDeathAnimationLayer

@onready var bullets_layer: Node2D = %BulletsLayer
@onready var darkness: PointLight2D = %Darkness
@onready var sun: Sun = %Sun

@onready var crt: ColorRect = %CRT
@onready var night_vision: ColorRect = %Night_Vision

@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var screen_transitions_manager: ScreenTransitionsManagerClass = ScreenTransitionsManager
@onready var audio_manager: AudioManagerClass = AudioManager
@onready var signals_manager: SignalsManagerClass = SignalsManager


func _tween_darkness_energy(to_amount: float) -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(darkness, "energy", to_amount, 1)


func _on_new_day(_day_count: int) -> void:
	if game_progression_manager.day_count == 10:
		resource_manager.outcome = "win"
		resource_manager.stats_dict = game_progression_manager.get_stats_dict()
		screen_transitions_manager.change_scene_to_packed_scene(resource_manager.END_SCENE)
	
	audio_manager.play_music(audio_manager.SNEAK_DAY_MAIN_LAYER, "SNEAK_DAY_MAIN")
	audio_manager.play_music(audio_manager.SNEAK_DAY_ALERT_LAYER, "SNEAK_DAY_ALERT", -72)
	if audio_manager.music_layer.has_node("SNEAK_NIGHT_MAIN"):
		audio_manager.dim_and_kill_stream("SNEAK_NIGHT_MAIN")
	if audio_manager.music_layer.has_node("SNEAK_NIGHT_ALERT"):
		audio_manager.dim_and_kill_stream("SNEAK_NIGHT_ALERT")
	night_vision.hide()
	darkness.show()
	_tween_darkness_energy(day_darkness_dim)
	await hud.flash_message("Day Light... Enemies shoot on sight")
	await get_tree().create_timer(2).timeout
	
	if ! resource_manager.has_day_tutorial_played:
		resource_manager.has_day_tutorial_played = true
		var day_tutorial: CanvasLayer = resource_manager.DAY_OVERLAY.instantiate() as CanvasLayer
		add_child(day_tutorial)
		get_tree().paused = true
	

func _on_new_night() -> void:
	audio_manager.play_music(audio_manager.SNEAK_NIGHT_MAIN_LAYER, "SNEAK_NIGHT_MAIN")
	audio_manager.play_music(audio_manager.SNEAK_NIGHT_ALERT_LAYER, "SNEAK_NIGHT_ALERT", -72)
	if audio_manager.music_layer.has_node("SNEAK_DAY_MAIN"):
		audio_manager.dim_and_kill_stream("SNEAK_DAY_MAIN")
	if audio_manager.music_layer.has_node("SNEAK_DAY_ALERT"):
		audio_manager.dim_and_kill_stream("SNEAK_DAY_ALERT")
	_tween_darkness_energy(night_darkness_dim)
	await hud.flash_message("Going Dark... Activating Night Vision")
	await get_tree().create_timer(2).timeout

	if ! resource_manager.has_night_tutorial_played:
		resource_manager.has_night_tutorial_played = true
		var night_tutorial: CanvasLayer = resource_manager.NIGHT_OVERLAY.instantiate() as CanvasLayer
		add_child(night_tutorial)
		get_tree().paused = true

	audio_manager.play_sfx(audio_manager.NIGHT_VISION_GOGGLES, "NIGHT_VISION_GOGGLES")
	night_vision.show()
	darkness.hide()


func _check_if_in_alert_or_chase() -> bool:
	if sun.sun_lightsource.light_hitting_player:
		return true
	for child in enemies_layer.get_children():
		var enemy_child: Enemy = child as Enemy
		if enemy_child.enemy_state_machine.current_state in [enemy_child.enemy_state_machine.alerted, enemy_child.enemy_state_machine.chase]:
			return true
	return false


func _on_player_died() -> void:
	hud.hide()
	resource_manager.outcome = "lose"
	resource_manager.stats_dict = game_progression_manager.get_stats_dict()
	await screen_transitions_manager.mask_on(Color.BLACK, 3)
	screen_transitions_manager.change_scene_to_packed_scene(resource_manager.END_NARRATIVE_SCENE)


func _ready() -> void:
	audio_manager.dim_and_kill_all_streams()
	screen_transitions_manager.mask_off()
	signals_manager.new_day.connect(_on_new_day)
	signals_manager.new_night.connect(_on_new_night)
	player.hp_component.died_signal.connect(_on_player_died)
	
	game_progression_manager.start_game()
	

func _process(_delta: float) -> void:
	if _check_if_in_alert_or_chase():
		if audio_manager.music_layer.has_node("SNEAK_DAY_ALERT"):
			audio_manager.music_layer.get_node("SNEAK_DAY_ALERT").set("volume_db", 0)
		if audio_manager.music_layer.has_node("SNEAK_NIGHT_ALERT"):
			audio_manager.music_layer.get_node("SNEAK_NIGHT_ALERT").set("volume_db", 0)
	
	else:
		if audio_manager.music_layer.has_node("SNEAK_DAY_ALERT"):
			audio_manager.music_layer.get_node("SNEAK_DAY_ALERT").set("volume_db", -72)
		if audio_manager.music_layer.has_node("SNEAK_NIGHT_ALERT"):
			audio_manager.music_layer.get_node("SNEAK_NIGHT_ALERT").set("volume_db", -72)		
