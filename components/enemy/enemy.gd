class_name Enemy
extends CharacterBody2D

@export var max_hp: float = 10
@export var idle_duration: float = 2

@export var min_move_distance: float = 1000
@export var max_move_distance: float = 1500

@export var rotation_speed: float = 2.0

@export var patrol_movement_speed: float = 100.0
@export var chasing_movement_speed: float = 150.0

@export var take_down_interval: float = 0.5
@export var shooting_range: float = 500
@export var reload_time: float = 2
@export var bullet_damage: float = 1
@export var bullet_speed: float = 600

@onready var enemy_state_machine: EnemyStateMachine = %EnemyStateMachine
@onready var hp_component: HPComponent = %HPComponent
@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D

@onready var allies_alert_radius: Area2D = %AlliesAlertRadius
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var takedown_area: Area2D = %TakedownArea
@onready var lightsource: Lightsource = %EnemyLightsource

@onready var muzzle_marker: Marker2D = %MuzzleMarker
@onready var shooting_raycast: RayCast2D = %ShootingRaycast

@onready var health_bar: HealthBar = %HealthBar
@onready var takedown_placeholder: Label = %TakedownPlaceholder

@onready var pivot_point: Marker2D = %PivotPoint
@onready var status_alert_sprite: AnimatedSprite2D = %StatusAlertSprite


@onready var game_progression_manager: GameProgressionManager = get_tree().get_first_node_in_group("game_progression_manager")
@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var audio_manager: AudioManagerClass = AudioManager

var play_scene: PlayScene
var enemies_manager: EnemiesManager

var takedown_possible: bool
var in_takedown: bool


var animation_segment_angles_array: Array = []
var animation_names_by_segments: Array[String] = ["walk_right", "walk_bottom_right", "walk_front", "walk_bottom_left", "walk_left", "walk_top_left", "walk_back", "walk_top_right"]


func _init_enemy() -> void:
	hp_component.max_hp = max_hp
	hp_component.current_hp = max_hp


func _on_body_entered(other_body: Node2D) -> void:
	if other_body is Player:
		takedown_possible = true
	

func _on_body_exited(other_body: Node2D) -> void:
	if other_body is Player:
		takedown_possible = false


func _get_array_split_angles_by_segments(num_segments: int, offset_from_x0: bool = false) -> Array:
	var result: Array = []
	var angle_per_segment: float = TAU / num_segments
	var offset_angle_from_x0: float = 0
	if offset_from_x0:
		offset_angle_from_x0 = TAU - ( angle_per_segment / 2 )
	for i in num_segments:
		var starting_angle: float = offset_angle_from_x0 + (i * angle_per_segment)
		starting_angle = wrapf( starting_angle, 0, TAU )
		var ending_angle: float = offset_angle_from_x0 + ( (i + 1) * angle_per_segment )
		ending_angle = wrapf( ending_angle, 0, TAU )
		var segment_pair: Array[float] = [starting_angle, ending_angle]
		result.append(segment_pair)
	return result


func _set_animated_sprite() -> void:
	var pivot_rotation: float = pivot_point.rotation
	pivot_rotation = wrapf(pivot_rotation, 0, TAU)
	
	var animation_segment_index: int
	
	for segment_pair_angles: Array in animation_segment_angles_array:
		if ( pivot_rotation >= segment_pair_angles[0] ) and ( pivot_rotation < segment_pair_angles[1] ):
			animation_segment_index = animation_segment_angles_array.find( segment_pair_angles )
	
	animated_sprite_2d.play( animation_names_by_segments[animation_segment_index] )
	

func _process(delta: float) -> void:
	takedown_placeholder.visible = takedown_possible
	
	if enemy_state_machine:
		enemy_state_machine.override_process(delta)
		

func _physics_process(delta: float) -> void:
	if enemy_state_machine:
		enemy_state_machine.override_physics_process(delta)
	
	if hp_component.is_dead:
		animated_sprite_2d.play("die")
		return
	
	if enemy_state_machine.current_state == enemy_state_machine.stun:
		return
	
	if velocity != Vector2.ZERO:
		_set_animated_sprite()


func _ready() -> void:
	_init_enemy()
	randomize()
	animation_segment_angles_array = _get_array_split_angles_by_segments(8, true)
	takedown_area.body_entered.connect(_on_body_entered)
	takedown_area.body_exited.connect(_on_body_exited)
	hp_component.died_signal.connect(destroy)
	shooting_raycast.target_position = Vector2(shooting_range, 0)
	lightsource.enable( game_progression_manager.current_phase == "night" )


func destroy() -> void:
	game_progression_manager.enemies_killed += 1
	game_progression_manager.current_exp += 1
	
	if enemy_state_machine.current_state == enemy_state_machine.stun:
		game_progression_manager.enemies_takedown_kills += 1
		audio_manager.play_sfx(audio_manager.enemy_takedown_death_sounds.pick_random() as AudioStream, "enemy_takedown_death")
	
	else:
		audio_manager.play_sfx(audio_manager.ENEMY_DIE_SHOT, "ENEMY_DIE_SHOT")
	
	var enemy_death_anim_instance: EnemyDeathAnimation = resource_manager.ENEMY_DEATH_ANIMATION_SCENE.instantiate() as EnemyDeathAnimation
	enemy_death_anim_instance.global_position = global_position
	play_scene.enemies_death_animation_layer.add_child(enemy_death_anim_instance)
	
	call_deferred("queue_free")
