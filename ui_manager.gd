extends Node

@onready var game_over_layer: CanvasLayer = $GameOverLayer
@onready var color_rect: ColorRect = $GameOverLayer/ColorRect



func _ready():
	# 노드가 존재하는지 한 번 더 확인 (안전장치)
	if game_over_layer:
		game_over_layer.hide()
	else:
		print("경고: GameOverLayer 노드를 찾을 수 없습니다! 경로를 확인하세요.")
		
	GlobalGameEvents.game_over.connect(_on_game_over)

func _on_game_over():
	if game_over_layer:
		game_over_layer.show()
