class_name ResourceManagerClass
extends Node

var MAIN_MENU: PackedScene = preload("res://scenes/main_menu/main_menu.tscn")
var SETTINGS_POPUP: PackedScene = preload("res://components/settings_popup/settings_popup.tscn")

var NARRATIVE_SCENE: PackedScene = preload("res://scenes/narrative_scene/narrative_scene.tscn")
var PLAY_SCENE: PackedScene = preload("res://scenes/play_scene/play_scene.tscn")
var END_NARRATIVE_SCENE: PackedScene = preload("res://scenes/end_narrative_scene/end_narrative_scene.tscn")
var END_SCENE: PackedScene = preload("res://scenes/end_scene/end_scene.tscn")

var UPGRADE_CHOICES_OVERLAY: PackedScene = preload("res://components/upgrade_choice_overlay/upgrade_choices_overlay.tscn")

var ENEMY: PackedScene = preload("res://components/enemy/enemy.tscn")
var BULLET: PackedScene = preload("res://components/bullet/bullet.tscn")
var ENEMY_DEATH_ANIMATION_SCENE: PackedScene = preload("res://components/enemy/enemy_death_animation/enemy_death_animation.tscn")

var DAY_OVERLAY: PackedScene = preload("res://scenes/overlays/day overlay/day_overlay.tscn")
var NIGHT_OVERLAY: PackedScene  = preload("res://scenes/overlays/night overlay/night_overlay.tscn")

var has_intro_narrative_played: bool = false
var has_day_tutorial_played: bool = false
var has_night_tutorial_played: bool = false


var outcome: String
var stats_dict: Dictionary


func reset() -> void:
	outcome = ""
	stats_dict = {}
