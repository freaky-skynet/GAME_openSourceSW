extends HBoxContainer

# 하트 이미지 리소스 경로
@export var heart_texture = preload("res://Hearts.png")
var heart_script = preload("res://scripts/ui/heart_sprite.gd")

func _ready():
	# 체력 변경 소식이 들리면 업데이트 함수 실행
	GlobalGameEvents.hp_changed.connect(_on_hp_changed)
	
	# 목슴 갯수
	setup_hearts(5)

func setup_hearts(max_hp: int):
	# 기존 하트 비우기
	for child in get_children():
		child.queue_free()
		
	# 하트 생성 
	for i in range(max_hp):
		var heart_container = Control.new()
		# 하트 스프라이트 크기에 맞춰서 방 크기 지정
		heart_container.custom_minimum_size = Vector2(25, 25)
		
		# 실제 애니메이션을 돌릴 Sprite2D 생성
		var heart_sprite = Sprite2D.new()
		heart_sprite.texture = heart_texture
		heart_sprite.set_script(heart_script)
		
		heart_sprite.hframes = 6 
		heart_sprite.vframes = 7
		heart_sprite.centered = false
		heart_sprite.position = Vector2(0, 0)
		heart_sprite.scale=Vector2(1.5,1.5)
		
		heart_container.add_child(heart_sprite)
		add_child(heart_container)

func _on_hp_changed(current_hp: int):
	var valid_hearts = []
	for child in get_children():
		if not child.is_queued_for_deletion():
			valid_hearts.append(child)
			
	var total_hearts = valid_hearts.size()
	
	for i in range(total_hearts):
		if i < current_hp:
			valid_hearts[i].modulate.a = 1.0
		else:
			valid_hearts[i].modulate.a = 0.0
