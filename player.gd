extends CharacterBody2D

@export var speed: float = 400.0 #이동 속도
@export var bullet_scene: PackedScene
@onready var shoot_timer=$ShootTimer

func _physics_process(_delta):
	# 1. 입력 벡터 가져오기 (상하좌우 키 설정을 한 번에 처리)
	# "left", "right", "up", "down"은 Input Map에서 설정한 이름
	var direction = Input.get_vector("left", "right", "up", "down")
	
	# 2. 이동 방향이 있을 때만 속도 설정
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		# 서서히 멈추고 싶다면 lerp
		# 즉각적인 정지는 zero
		velocity = Vector2.ZERO
	
	#이동 및 충돌 처리
	move_and_slide()
	
func _process(_delta):
	# 'fire' 키를 누르기 시작할 때
	if Input.is_action_just_pressed("fire"):
		start_shooting()
	
	# 'fire' 키를 뗐을 때
	if Input.is_action_just_released("fire"):
		stop_shooting()

func start_shooting():
	shoot_timer.start()
	shoot() # 누르자마자 첫 발은 바로 발사

func stop_shooting():
	shoot_timer.stop()

# 타이머의 'timeout' 시그널을 연결
func _on_shoot_timer_timeout():
	shoot()
	
func shoot():
	if bullet_scene:
	# 1. 총알 인스턴스 생성
		var bullet = bullet_scene.instantiate()
		
# 2. BulletManager 노드 찾기
		var bullet_manager = get_node_or_null("../../BulletManager") 
		if bullet_manager:
			bullet_manager.add_child(bullet)
		else:
			# 혹시라도 매니저를 못 찾으면 게임이 멈추지 않게 루트에라도 넣어줌
			get_tree().root.add_child(bullet)
		# 3. 위쪽 방향 설정 # 고도 엔진에서 위쪽은 Vector2.UP (0, -1)
		var direction = Vector2.UP 
		var shoot_point = global_position
		# 4. 발사 실행 (위치와 방향 전달)
		bullet.launch(shoot_point, direction)
