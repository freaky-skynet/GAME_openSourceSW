extends Control

@export_file("*.tscn") var game_scene_path: String = "res://scenes/main/world.tscn"
@export var guide_show_time: float = 2.0
# 조작법 이미지 보여줄 시간


@onready var start_button: Button = $StartButton
@onready var start_ranking_label: Label = $StartRankingLabel
@onready var guide_image: TextureRect = $GuideImage

var is_starting: bool = false

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	start_ranking_label.text = RankingManager.get_ranking_text()
	guide_image.visible = false

func _on_start_button_pressed() -> void:
	if is_starting:
		return
	
	guide_image.visible = true
	guide_image.move_to_front()
	
	await get_tree().create_timer(guide_show_time).timeout
	
	get_tree().change_scene_to_file(game_scene_path)
	
