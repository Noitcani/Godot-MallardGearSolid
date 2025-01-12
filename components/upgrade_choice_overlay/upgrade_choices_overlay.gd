class_name UpgradeChoicesOverlay
extends CanvasLayer

@export var upgrade_card_scene: PackedScene

@onready var upgrade_cards_hbox: HBoxContainer = %UpgradeCardsHbox
@onready var confirm_choice_button: Button = %ConfirmChoiceButton
@onready var game_progression_manager: GameProgressionManager = get_tree().get_first_node_in_group("game_progression_manager")
@onready var upgrades_manager: UpgradesManager = get_tree().get_first_node_in_group("upgrades_manager")

@onready var audio_manager: AudioManagerClass = AudioManager

var number_of_choices: int = 3
var currently_selected_card: UpgradeCard


func _spawn_upgrade_cards(number_of_cards: int) -> void:
	var full_buff_array: Array[Upgrade] = upgrades_manager.buff_array.duplicate()
	var full_debuff_array: Array[Upgrade] = upgrades_manager.debuff_array.duplicate()
	
	full_buff_array.shuffle()
	full_debuff_array.shuffle()
	
	if number_of_cards > full_buff_array.size():
		number_of_cards = full_buff_array.size()
	
	for i in number_of_cards:
		var upgrade_card_instance: UpgradeCard = upgrade_card_scene.instantiate() as UpgradeCard
		
		upgrade_card_instance.buff = full_buff_array.pop_back()
		upgrade_card_instance.debuff = full_debuff_array.pop_back()
		
		upgrade_card_instance.card_selected.connect(_on_card_selected.bind(upgrade_card_instance))
		upgrade_cards_hbox.add_child(upgrade_card_instance)


func _on_card_selected(selected_upgrade_card: UpgradeCard) -> void:
	audio_manager.play_sfx(audio_manager.MENU_SELECT, "MENU_SELECT")
	currently_selected_card = selected_upgrade_card
	for child in upgrade_cards_hbox.get_children():
		child.set("is_selected", child == selected_upgrade_card)
		
	confirm_choice_button.disabled = currently_selected_card == null
	

func _hide_non_selected_cards(selected_upgrade_card: UpgradeCard) -> void:
	for child in upgrade_cards_hbox.get_children():
		if child != selected_upgrade_card:
			child.call("hide")


func _on_confirm_choice() -> void:
	audio_manager.play_sfx(audio_manager.MENU_EXIT, "MENU_EXIT")
	_hide_non_selected_cards(currently_selected_card)
	currently_selected_card.apply_effects()
	queue_free()
	get_tree().paused = false
	game_progression_manager.level_up_complete()


func _ready() -> void:
	confirm_choice_button.disabled = true
	confirm_choice_button.pressed.connect(_on_confirm_choice)
	_spawn_upgrade_cards(number_of_choices)

