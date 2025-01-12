class_name EndNarrativeScene
extends Node2D

@onready var narrative_container: PanelContainer = %NarrativeContainer
@onready var narrative_label: Label = %NarrativeLabel
@onready var next_button: Button = %NextButton

@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var screen_transitions_manager: ScreenTransitionsManagerClass = ScreenTransitionsManager
@onready var audio_manager: AudioManagerClass = AudioManager

var narrative_script: Array[String] = []

var win_narrative_script: Array[String] = [
	"Drake! Great job holding out!",
	"Our extraction forces have arrived.",
	"Quacktastical job, we're bringing you home!"
]

var lose_narrative_script: Array[String] = [
	"Drake!!! Are you there? Can you hear me??!!",
	"Drake...?? Drake?!",
	"DRAKEEEEEEEEEEEEE.....!!",
	"<Transmission Lost...>",
]


var narrative_index: int = 0
var is_playing: bool
var is_finished: bool


func _init_scene() -> void:
	if resource_manager.outcome == "win":
		narrative_script = win_narrative_script
	else:
		narrative_script = lose_narrative_script

	next_button.pressed.connect(_on_next_button_pressed)
	narrative_container.modulate.a = 0
	await VfxUtils2D.fade_in(narrative_container, 1)
	_play_narrative(0)
	

func _on_next_button_pressed() -> void:
	if ! is_finished and is_playing:
		is_playing = false
		
	if is_finished:
		if narrative_index < narrative_script.size() - 1:
			narrative_index += 1
			_play_narrative(narrative_index)
		
		else:
			audio_manager.play_sfx(audio_manager.START_GAME, "START_GAME")
			screen_transitions_manager.change_scene_to_packed_scene(resource_manager.END_SCENE)


func _play_narrative(script_index: int) -> void:
	narrative_label.text = ""
	is_finished = false
	is_playing = true
	
	var next_line: String = narrative_script[script_index]
	var line_pointer: int = 0
	
	while is_playing:
		narrative_label.text += next_line[line_pointer]
		await get_tree().create_timer(0.02).timeout
		
		if line_pointer < next_line.length() - 1:
			line_pointer += 1
		else:
			is_playing = false
	
	narrative_label.text = next_line
	await get_tree().create_timer(0.5).timeout
	is_finished = true


func _ready() -> void:
	audio_manager.dim_and_kill_all_streams()
	audio_manager.play_music(audio_manager.TEXT_SCROLL_001, "TEXT_SCROLL_001", -72)
	_init_scene()
	screen_transitions_manager.mask_off()
	

func _process(_delta: float) -> void:
	if is_playing:
		if audio_manager.music_layer.has_node("TEXT_SCROLL_001"):
			audio_manager.music_layer.get_node("TEXT_SCROLL_001").set("volume_db", 0)	
	
	if is_playing or is_finished:
		next_button.disabled = false
	else:
		next_button.disabled = true
		if audio_manager.music_layer.has_node("TEXT_SCROLL_001"):
			audio_manager.music_layer.get_node("TEXT_SCROLL_001").set("volume_db", -72)
