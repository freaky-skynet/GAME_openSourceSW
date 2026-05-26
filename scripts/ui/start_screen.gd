extends Control

@export_file("*.tscn") var game_scene_path: String = "res://scenes/main/world.tscn"

@onready var start_button: Button = $StartButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)
