extends Sprite2D

@export var fps: float = 8.0
@export var start_frame: int = 0
@export var end_frame: int = 5

var current_frame_index: float = 0.0

func _ready():
	# 인스펙터 설정 대신 코드가 실행될 때 자동으로 격자로 쪼개기
	hframes = 6
	vframes = 7
	frame = start_frame
	current_frame_index = float(start_frame)

func _process(delta: float):
	current_frame_index += delta * fps
	if current_frame_index > (end_frame + 1):
		current_frame_index = float(start_frame)
	frame = int(current_frame_index)
