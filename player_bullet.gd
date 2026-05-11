extends Area2D

@export var speed: float = 500.0 # 총알 속도
var direction: Vector2 = Vector2.ZERO # 날아갈 방향을 저장할 변수

func _process(delta):
# 매 프레임마다 정해진 방향으로 speed만큼 이동
	position += direction * speed * delta
# 플레이어가 소환할 때 호출하는 함수 (이게 없어서 에러가 났던 거야!)
func launch(start_pos: Vector2, target_dir: Vector2):
	global_position = start_pos # 시작 위치 설
	direction = target_dir

func _on_body_entered(body):
	# 닿은 대상(body)이 CharacterBody2D인지 확인해!
	if body is CharacterBody2D:
		# 여기에 적에게 데미지를 주는 코드를 넣어도 좋아...!
		queue_free()
