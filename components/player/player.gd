class_name Player
extends CharacterBody2D

enum PLAYER_STATES {IDLE, IN_TAKEDOWN, RELOADING, ROLLING}

@export var shot_cooldown_interval: float = 1.5

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var collision_shape_shape: RectangleShape2D = collision_shape_2d.shape
@onready var takedown_detection_area: Area2D = %TakedownDetectionArea
@onready var hp_component: HPComponent = %HPComponent
@onready var reloading_progress_display: TextureProgressBar = %ReloadingProgressDisplay

@onready var player_camera: PlayerCamera = %PlayerCamera
@onready var shot_cooldown_timer: Timer = %ShotCooldownTimer
@onready var roll_cooldown_timer: Timer = %RollCooldownTimer

@onready var resource_manager: ResourceManagerClass = ResourceManager
@onready var audio_manager: AudioManagerClass = AudioManager
@onready var play_scene: PlayScene = get_tree().get_first_node_in_group("play_scene")
@onready var hud: HUD = get_tree().get_first_node_in_group("hud")
@onready var game_progression_manager: GameProgressionManager = get_tree().get_first_node_in_group("game_progression_manager")


var player_state: PLAYER_STATES
var move_speed: float = 320.0
var roll_distance: float = 300
var roll_duration: float = 0.5
var roll_cooldown_interval: float = 4
var last_moved_direction: Vector2

var in_takedown_areas: bool

var bullet_damage: int = 5

var max_ammo_capacity: int:
	set(new_amount):
		max_ammo_capacity = new_amount
		hud.max_ammo_capacity = new_amount

var current_ammo: int:
	set(new_amount):
		current_ammo = new_amount
		hud.update_ammo_display()

var reload_time: float = 2


func _init_player() -> void:
	max_ammo_capacity = 4
	current_ammo = max_ammo_capacity


func _check_if_in_takedown_areas() -> void:
	if takedown_detection_area.has_overlapping_areas():
		in_takedown_areas = true
	else:
		in_takedown_areas = false
		if player_state == PLAYER_STATES.IN_TAKEDOWN:
			player_state = PLAYER_STATES.IDLE
	

func _set_animation(_direction: Vector2) -> void:
	if _direction == Vector2.ZERO:
		if animated_sprite_2d.animation == "roll":
			animated_sprite_2d.play("idle_front")
		else:
			animated_sprite_2d.stop()
		return
	
	if abs(_direction.y) > abs(_direction.x):
		if _direction.y < 0:
			if animated_sprite_2d.animation != "walk_back" or ! animated_sprite_2d.is_playing():
				animated_sprite_2d.play("walk_back")
				return

		if _direction.y > 0:
			if animated_sprite_2d.animation != "walk_front" or ! animated_sprite_2d.is_playing():
				animated_sprite_2d.play("walk_front")
				return
	
	else:
		if _direction.x < 0:
			if animated_sprite_2d.animation != "walk_left" or ! animated_sprite_2d.is_playing():
				animated_sprite_2d.play("walk_left")
				return
		if _direction.x > 0:
			if animated_sprite_2d.animation != "walk_right" or ! animated_sprite_2d.is_playing():
				animated_sprite_2d.play("walk_right")
				return


func _shoot_bullet(direction: Vector2) -> void:
	if current_ammo <= 0:
		if ! hud.message_flash_label.visible:
			hud.flash_message("Out of Ammo! Reload with 'R'!", 1)
		return
	
	_set_animation(direction)
	audio_manager.play_sfx( audio_manager.player_gunshot_sounds.pick_random() as AudioStream, "player_gunshot" )
	var bullet_instance: Bullet = resource_manager.BULLET.instantiate() as Bullet
	bullet_instance.bullet_source = self
	bullet_instance.bullet_damage = bullet_damage
	bullet_instance.global_position = global_position
	bullet_instance.direction = direction
	play_scene.bullets_layer.add_child(bullet_instance)
	shot_cooldown_timer.start(shot_cooldown_interval)
	current_ammo = max(0, current_ammo - 1)
	game_progression_manager.shots_fired += 1


func _reload() -> void:
	audio_manager.play_sfx(audio_manager.PLAYER_RELOAD, "PLAYER_RELOAD")
	hud.flash_message("Reloading...", reload_time)
	player_state = PLAYER_STATES.RELOADING
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(reloading_progress_display, "value", 0, 0)
	tween.tween_callback(reloading_progress_display.show)
	tween.tween_property(reloading_progress_display, "value", 1, reload_time)
	tween.tween_callback(reloading_progress_display.hide)
	await tween.finished
	current_ammo = max_ammo_capacity
	player_state = PLAYER_STATES.IDLE


func _roll(in_direction: Vector2) -> void:
	audio_manager.play_sfx(audio_manager.PLAYER_ROLL, "PLAYER_ROLL")
	roll_cooldown_timer.start(roll_cooldown_interval)
	animated_sprite_2d.play("roll", 1 / roll_duration)
	set_collision_layer_value(1, false)
	player_state = PLAYER_STATES.ROLLING
	velocity = ( 250 * in_direction.normalized() ) / roll_duration
	await get_tree().create_timer(roll_duration).timeout
	set_collision_layer_value(1, true)
	player_state = PLAYER_STATES.IDLE


func _on_player_died() -> void:
	hp_component.is_dead = true
	set_collision_layer_value(1, false)
	audio_manager.play_sfx(audio_manager.PLAYER_DIE, "PLAYER_DIE")


func _ready() -> void:
	_init_player()
	hp_component.died_signal.connect(_on_player_died)


func _physics_process(_delta: float) -> void:
	if hp_component.is_dead: return
	_check_if_in_takedown_areas()
	
	if player_state == PLAYER_STATES.IN_TAKEDOWN:
		if animated_sprite_2d.animation != "takedown":
			animated_sprite_2d.play("takedown")
			return
	
	if player_state == PLAYER_STATES.IDLE or player_state == PLAYER_STATES.RELOADING:
		_set_animation(velocity)
		var direction_x := Input.get_axis("move_left", "move_right")
		var direction_y := Input.get_axis("move_up", "move_down")
		
		var direction: Vector2 = Vector2(direction_x, direction_y).normalized()
		if direction != Vector2.ZERO:
			velocity = direction * move_speed
			
			if player_state == PLAYER_STATES.RELOADING:
				velocity /= 2
			
			last_moved_direction = direction
			move_and_slide()
			return

		else:
			velocity = Vector2.ZERO
			return
	
	if player_state == PLAYER_STATES.ROLLING:
		move_and_slide()
		return


func _unhandled_input(event: InputEvent) -> void:
	if hp_component.is_dead: return
	
	if event.is_action_pressed("attack"):
		if in_takedown_areas:
			player_state = PLAYER_STATES.IN_TAKEDOWN
			for node in takedown_detection_area.get_overlapping_areas():
				if node is EnemyTakedownArea:
					var takedown_area: EnemyTakedownArea = node as EnemyTakedownArea
					if takedown_area.enemy.enemy_state_machine.current_state != takedown_area.enemy.enemy_state_machine.stun:
						takedown_area.enemy.enemy_state_machine.current_state.transition_to_state("Stun")
		
		if ! in_takedown_areas and shot_cooldown_timer.is_stopped() and player_state != PLAYER_STATES.RELOADING:
			if event is InputEventMouseButton:
				var shooting_direction: Vector2 =  global_position.direction_to( get_global_mouse_position() )
				_shoot_bullet(shooting_direction)
		return

	if event.is_action_released("attack"):
		if player_state == PLAYER_STATES.IN_TAKEDOWN:
			player_state = PLAYER_STATES.IDLE
		return
	
	if event.is_action_pressed("roll") and player_state == PLAYER_STATES.IDLE:
		if roll_cooldown_timer.is_stopped():
			if event is InputEventMouseButton:
				var rolling_direction: Vector2
				
				if velocity == Vector2.ZERO:
					rolling_direction = global_position.direction_to( get_global_mouse_position() )
				else:
					rolling_direction = velocity
				
				_roll(rolling_direction)
		return
	
	if event.is_action_pressed("reload"):
		_reload()
		
