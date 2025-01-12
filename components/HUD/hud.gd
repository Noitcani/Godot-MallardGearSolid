class_name HUD
extends CanvasLayer

@export var ammo_display_scene: PackedScene

@onready var play_scene: PlayScene = get_tree().get_first_node_in_group("play_scene")
@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var day_night_widget: VBoxContainer = %DayNightWidget
@onready var current_phase_label: Label = %CurrentPhaseLabel
@onready var time_to_next_phase: Label = %TimeToNextPhase

@onready var enemies_left_widget: VBoxContainer = %EnemiesLeftWidget
@onready var enemies_left_label_label: Label = %EnemiesLeftLabelLabel
@onready var enemies_left_label: Label = %EnemiesLeftLabel

@onready var ammo_widget: HBoxContainer = %AmmoWidget

@onready var exp_bar: ProgressBar = %ExpBar
@onready var player_level_label: Label = %PlayerLevelLabel
@onready var enemies_killed_label: Label = %EnemiesKilledLabel


@onready var message_flash_label: Label = %MessageFlashLabel


var max_ammo_capacity: int:
	set(new_amount):
		var amount_of_ammo_display_to_add: int = new_amount - ammo_widget.get_child_count()
		if amount_of_ammo_display_to_add > 0:
			add_max_ammo_display(amount_of_ammo_display_to_add)
		max_ammo_capacity = new_amount


func _ready() -> void:
	max_ammo_capacity = player.max_ammo_capacity


func _process(_delta: float) -> void:
	day_night_widget.visible = ! play_scene.game_progression_manager.day_night_timer.is_stopped()
	current_phase_label.text = "{0} {1}".format([ play_scene.game_progression_manager.current_phase.capitalize(), str("%02d" % (play_scene.game_progression_manager.day_count + 1)) ])
	time_to_next_phase.text = "{0} Seconds to {1}".format([ str("%02d" % play_scene.game_progression_manager.day_night_timer.time_left), play_scene.game_progression_manager.next_phase.capitalize() ])

	enemies_left_widget.visible = ! play_scene.game_progression_manager.day_night_timer.is_stopped()
	enemies_left_label.text = str( "%02d" % play_scene.enemies_layer.get_child_count() )


func flash_message(message: String, flash_duration: float = 2) -> void:
	message_flash_label.text = message
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(message_flash_label, "modulate:a", 0, 0)
	tween.tween_callback(message_flash_label.show)
	tween.tween_property(message_flash_label, "modulate:a", 1, flash_duration/3)
	tween.tween_interval(flash_duration/3)
	tween.tween_property(message_flash_label, "modulate:a", 0, flash_duration/3)
	tween.tween_callback(message_flash_label.hide)
	await tween.finished


func add_max_ammo_display(amount_to_add: int) -> void:
	for i in amount_to_add:
		var ammo_display_instance: AmmoDisplay = ammo_display_scene.instantiate() as AmmoDisplay
		ammo_widget.add_child(ammo_display_instance)

	update_ammo_display()
		
		
func update_ammo_display() -> void:
	var current_ammo: int = player.current_ammo
	var ammo_display_array: Array[Node] = ammo_widget.get_children().duplicate()
	ammo_display_array.reverse()
	
	for child in ammo_display_array:
		if child is AmmoDisplay:
			var ammo_display_child: AmmoDisplay = child as AmmoDisplay
			if current_ammo > 0:
				ammo_display_child.enable_ammo_display(true)
			else:
				ammo_display_child.enable_ammo_display(false)
			
			current_ammo = max(0, current_ammo - 1)
