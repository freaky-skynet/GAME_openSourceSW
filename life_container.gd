extends HBoxContainer

# 하트 이미지 리소스
@export var heart_texture = preload("res://bossBullet.png") 

func _ready():
	# "체력 변경" 소식이 들리면 업데이트 함수 실행
	GlobalGameEvents.hp_changed.connect(_on_hp_changed)
	
	# 처음 시작할 때 하트 3개 세팅
	setup_hearts(3)

func setup_hearts(max_hp: int):
	# 기존 하트 싹 비우기
	for child in get_children():
		child.queue_free()
		
	# 하트 생성 
	for i in range(max_hp):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		# 크기 조절 설정
		heart.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(heart)

func _on_hp_changed(current_hp: int):
	# 자식 노드들의 개수를 현재 체력에 맞춰서 조절
	var hearts = get_children()
	for i in range(hearts.size()):
		# 현재 체력보다 순서가 높으면 하트를 숨김
		if i < current_hp:
			hearts[i].show()
		else:
			hearts[i].hide()
