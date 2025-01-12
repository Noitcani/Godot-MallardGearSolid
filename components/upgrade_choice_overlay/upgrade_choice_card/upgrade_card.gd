class_name UpgradeCard
extends Panel

signal card_selected

@onready var buff_description_label: Label = %BuffDescriptionLabel
@onready var debuff_description_label: Label = %DebuffDescriptionLabel
@onready var selected_border: Panel = %SelectedBorder

@onready var play_scene: PlayScene = get_tree().get_first_node_in_group("play_scene")
@onready var player: Player = get_tree().get_first_node_in_group("player")


var upgrade_description: String

var buff: Upgrade
var debuff: Upgrade


var is_selected: bool = false:
	set(new_is_selected_status):
		is_selected = new_is_selected_status
		selected_border.visible = is_selected


func _init_card() -> void:
	buff_description_label.text = buff.upgrade_description
	debuff_description_label.text = debuff.upgrade_description


func _on_mouse_entered(is_mouse_entered: bool) -> void:
	if is_mouse_entered:
		modulate.a = 0.6
	else:
		modulate.a = 1


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered.bind(true))
	mouse_exited.connect(_on_mouse_entered.bind(false))
	_init_card()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_mouse_click: InputEventMouseButton = event as InputEventMouseButton
		if event_mouse_click.button_index == MOUSE_BUTTON_LEFT and event_mouse_click.is_pressed():
			card_selected.emit()


func apply_effects() -> void:
	buff.apply_effects(player, play_scene)
	debuff.apply_effects(player, play_scene)
