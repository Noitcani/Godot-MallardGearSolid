class_name EnemyStateMachine
extends Node

@export var enemy_parent: Enemy

@onready var idle: Node = %Idle
@onready var day_patrol: Node = %DayPatrol
@onready var day_shoot: Node = %DayShoot

@onready var patrol: Node = %Patrol
@onready var chase: Node = %Chase
@onready var stun: Node = %Stun
@onready var alerted: Node = %Alerted


@onready var signals_manager: SignalsManagerClass = SignalsManager


var current_state: EnemyState:
	set(new_state):
		current_state = new_state


func _init_all_child_states() -> void:
	for state: EnemyState in get_children():
		state.enemy_parent = enemy_parent
		state.enemy_state_machine = self
		state.player = get_tree().get_first_node_in_group("player")
		state.play_scene = get_tree().get_first_node_in_group("play_scene")
		state.play_area = get_tree().get_first_node_in_group("play_area")
	
	current_state = idle
	current_state.enter_state()


func _on_new_day(_day_count: int) -> void:
	enemy_parent.lightsource.enable(false)
	if current_state != stun:
		current_state.transition_to_state("Idle")


func _on_new_night() -> void:
	enemy_parent.lightsource.enable(true)
	if current_state != stun:
		current_state.transition_to_state("Idle")


func _ready() -> void:
	_init_all_child_states()
	signals_manager.new_day.connect(_on_new_day)
	signals_manager.new_night.connect(_on_new_night)


func override_process(_delta: float) -> void:
	if current_state:
		current_state.override_process(_delta)


func override_physics_process(_delta: float) -> void:
	if current_state:
		current_state.override_physics_process(_delta)


func _process(_delta: float) -> void:
	if enemy_parent.lightsource.light_hitting_player:
		if current_state != chase and current_state != stun:
			current_state.transition_to_state("Chase")
