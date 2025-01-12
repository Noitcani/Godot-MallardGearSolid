class_name Bullet
extends CharacterBody2D

var bullet_source: CharacterBody2D
var bullet_damage: float = 1
var bullet_speed: float = 800
var direction: Vector2

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var bullet_area: Area2D = %BulletArea

@onready var game_progression_manager: GameProgressionManager = get_tree().get_first_node_in_group("game_progression_manager")


func _init_bullet() -> void:
	rotation = transform.x.angle_to(direction)
	if bullet_source is Player:
		bullet_area.set_collision_mask_value(1, false)
		return
	if bullet_source is Enemy:
		bullet_area.set_collision_mask_value(2, false)
		return
	


func _on_body_entered(other_body: Node2D) -> void:
	if other_body is Player:
		var player_hit: Player = other_body
		player_hit.hp_component.take_damage(bullet_damage)
	
	if other_body is Enemy:
		var enemy_hit: Enemy = other_body
		enemy_hit.hp_component.take_damage(bullet_damage)
		game_progression_manager.shots_landed += 1
	
	queue_free()


func _ready() -> void:
	bullet_area.body_entered.connect(_on_body_entered)
	_init_bullet()


func _physics_process(_delta: float) -> void:
	velocity = direction * bullet_speed
	move_and_slide()
