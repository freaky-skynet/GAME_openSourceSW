extends Label

func _ready():
	GlobalGameEvents.score_updated.connect(_on_score_updated)
	
	# 처음에 0점으로 세팅
	text = "SCORE: 0"

func _on_score_updated(new_score: int):
	text = "SCORE: " + str(new_score)
