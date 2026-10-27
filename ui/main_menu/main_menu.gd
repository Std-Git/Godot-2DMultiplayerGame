extends Control

const PORT:int = 3000

var main_scene: PackedScene = preload("uid://bi5t875an0xjb")

@onready var single_player_button: Button = %SinglePlayerButton
@onready var multiplayer_button: Button = %MultiplayerButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton

@onready var multiplayer_menu_scene: PackedScene = load("uid://m1bn14p6yrgw")

var options_menu_scene: PackedScene = preload("uid://b4dnp5atlk6rp")

func _ready() -> void:
	single_player_button.pressed.connect(_on_single_player_button_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	options_button.pressed.connect(_on_options_pressed)
	
	UIAudioManager.register_buttons([
		single_player_button,
		multiplayer_button,
		options_button,
		quit_button
	])

func _on_single_player_button_pressed():
	get_tree().change_scene_to_packed(main_scene)
	
func _on_multiplayer_button_pressed():
	get_tree().change_scene_to_packed(multiplayer_menu_scene)
	
func _on_quit_button_pressed():
	get_tree().quit()

func _on_options_pressed():
	var options_menu := options_menu_scene.instantiate()
	add_child(options_menu)
