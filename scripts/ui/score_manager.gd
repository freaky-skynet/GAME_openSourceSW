extends Node

var total_score: int = 0 # 실제 점수가 저장되는 변수

func _ready():
	GlobalGameEvents.request_score_change.connect(_on_score_change_requested)

func _on_score_change_requested(amount: int):
	total_score += amount
	
	
	if total_score < 0:
		total_score = 0
		
	# 3. 계산이 끝났으니, 전광판(UI)에 방송.
	GlobalGameEvents.score_updated.emit(total_score)
	
	
