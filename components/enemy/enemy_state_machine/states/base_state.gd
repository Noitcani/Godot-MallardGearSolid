class_name EnemyState
extends Node

var enemy_parent: Enemy
var enemy_state_machine: EnemyStateMachine
var player: Player
var play_scene: PlayScene
var play_area: PlayArea

func _ready() -> void:
	pass


func override_process(_delta: float) -> void:
	pass


func override_physics_process(_delta: float) -> void:
	pass


func enter_state(_params: Dictionary = {}) -> void:
	pass


func exit_state(_params: Dictionary = {}) -> void:
	pass


func transition_to_state(next_state_name: String, params: Dictionary = {}) -> void:
	exit_state()
	var next_state: EnemyState = enemy_state_machine.get_node(next_state_name)
	if next_state:
		enemy_state_machine.current_state = next_state
		enemy_state_machine.current_state.enter_state(params)
