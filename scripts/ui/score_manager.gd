extends Node

var total_score: int = 0 # 실제 점수가 저장되는 변수

func _ready():
	GlobalGameEvents.request_score_change.connect(_on_score_change_requested)

func _on_score_change_requested(amount: int):
	total_score += amount
	
	
	if total_score < 0:
		total_score = 0
	
	# 클리어 화면에서 점수를 보여주기 위해 전역에 저장
	GlobalGameEvents.current_score = total_score

	# 전광판 UI에 전달
	GlobalGameEvents.score_updated.emit(total_score)
	
