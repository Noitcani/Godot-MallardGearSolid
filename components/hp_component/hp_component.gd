class_name HPComponent
extends Node
## Character component that tracks HP changes (e.g. damage/ heals)

## Emitted when hp value changes. Automatically emitted on [code]current_hp[/code] setter.
signal hp_changed_signal(new_hp: float)
## Emitted when hp falls below 0
signal died_signal

@export_category("Main Settings")
## Max HP value
@export var max_hp: float = 100
## Hit flash visuals toggle
@export var requires_hit_flash: bool = true
## IFrame duration
@export var has_iframe: bool = true
@export var iframe_duration: float = 0.5

@export_category("Internal References")
## Hit flash shader
@export var hit_flash_shader: Shader
## Damage hit flash shader color
@export var damage_hit_flash_color: Color = Color.GHOST_WHITE
## Heal hit flash shader color
@export var heal_hit_flash_color: Color = Color.GREEN_YELLOW
## Tracks iFrame duration. Immune to damage when on iFrame cooldown.
@onready var iframe_timer: Timer = $IFrameTimer


@export_category("External References")
## Owner Sprite. Optional if [code]requires_hit_flash[/code] is off.
@export var owner_sprite: CanvasItem
## Linked Health Bar. Optional
@export var health_bar: HealthBar

@onready var audio_manager: AudioManagerClass = AudioManager

## Toggle death status. Auto triggers when HP falls to 0.
var is_dead: bool = false

## Current HP value. Built-in setter function.
var current_hp: float:
	set(new_hp):
		if is_dead: return
		current_hp = clamp(new_hp, 0, max_hp)
		hp_changed_signal.emit(current_hp)
		
		if health_bar.progress_bar != null:
			var health_ratio: float = current_hp / max_hp
			health_bar._update_progress_bar(health_ratio)
		
		if current_hp <= 0:
			is_dead = true
			died_signal.emit()
		
## Hit Flash Shader Material
var hit_flash_shader_material: ShaderMaterial = ShaderMaterial.new()


## Ensure proper setup
func _setup_checks() -> void:
	if owner == null:
		printerr("HPComponent {0} Not attached to a valid parent".format([self]))
		return
	
	if requires_hit_flash:
		if owner_sprite == null:
			printerr("HPComponent {0} Target material not set".format([self]))
			return
		
		if hit_flash_shader == null:
			printerr("HPComponent {0} Hit_flash_shader not set".format([self]))
			return


## Attach exported hit flash shader to parent node, if valid.
func _attach_hit_flash_shader_to_owner_sprite() -> void:
	hit_flash_shader_material.shader = hit_flash_shader
	owner_sprite.material = hit_flash_shader_material


## Set hit flash shader active/inactive
func _set_hitflash(status: bool) -> void:
	hit_flash_shader_material.set_shader_parameter("active", status)


## Flash hit flash visual
func _hit_flash_tween(is_damage: bool) -> void:
	if is_damage:
		hit_flash_shader_material.set_shader_parameter("flash_color", damage_hit_flash_color)		
	
	elif ! is_damage:
		hit_flash_shader_material.set_shader_parameter("flash_color", heal_hit_flash_color)		
	
	var tween: Tween = create_tween()
	tween.tween_method(_set_hitflash, 0, 1, 0.2)
	tween.tween_method(_set_hitflash, 1, 0, 0.2)

		
func _ready() -> void:
	_setup_checks()
	if requires_hit_flash:
		_attach_hit_flash_shader_to_owner_sprite()
	current_hp = max_hp
	iframe_timer.wait_time = iframe_duration
	

## Resolves damage take. Flash hit flash if required.
func take_damage(damage_amount: float) -> void:
	if is_dead: return
	if has_iframe:
		if ! iframe_timer.is_stopped(): return
	
	current_hp -= damage_amount
	if requires_hit_flash:
		_hit_flash_tween(true)
	iframe_timer.start(iframe_duration)
	
	if owner is Enemy:
		audio_manager.play_sfx(audio_manager.enemy_hurt_sounds.pick_random() as AudioStream, "enemy_hurt")
	if owner is Player:
		owner.get_node("PlayerCamera").call("apply_screen_shake")
		audio_manager.play_sfx(audio_manager.player_hurt_sounds.pick_random() as AudioStream, "player_hurt")	


## Resolves heal recieved. Flash hit flash if required.
func take_heal(heal_amount: float) -> void:
	if is_dead: return
	
	current_hp += heal_amount
	if requires_hit_flash:
		_hit_flash_tween(false)
