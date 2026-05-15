extends CharacterBody2D

@export var speed: float = 400.0 #이동 속도
@onready var player_bullet_manager=%PlayerBulletManager
@onready var shoot_timer=$ShootTimer

func _physics_process(_delta):
	# 1. 입력 벡터 가져오기 (상하좌우 키 설정을 한 번에 처리)
	# "left", "right", "up", "down"은 Input Map에서 설정한 이름
	var direction = Input.get_vector("left", "right", "up", "down")
	
	# 2. 이동 방향이 있을 때만 속도 설정
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		#인풋없으면 정지 
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

func stop_shooting():
	shoot_timer.stop()
	if GlobalGameEvents.combo_level==3:
		player_bullet_manager.stop_laser()

# 타이머의 'timeout' 시그널을 연결
func _on_shoot_timer_timeout():
	shoot()
	
func shoot():
	var dir:Vector2=Vector2.UP
	player_bullet_manager.fire_bullet(global_position, dir)
