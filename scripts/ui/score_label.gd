extends Label

func _ready():
	GlobalGameEvents.score_updated.connect(_on_score_updated)
	
	# 처음에 0점으로 세팅
	text = "%08d" % 0

func _on_score_updated(new_score: int):
	text = "%08d" % new_score
