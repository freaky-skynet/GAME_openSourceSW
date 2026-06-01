extends CharacterBody2D
@export var is_invincible: bool = false
@export var speed: float = 400.0 #이동 속도
@export var player_half=16.0


@onready var player_bullet_manager=%PlayerBulletManager
@onready var shoot_timer=$ShootTimer
@onready var player_dash = $PlayerDash
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var barrier_sprite:AnimatedSprite2D=$BarrierSprite
@onready var explosion_sprite:AnimatedSprite2D=$ExplosionSprite
@onready var damaged_sfx:AudioStreamPlayer2D=$AudioStreamPlayer2D

var max_hp: int = 3
var current_hp: int = 3


func _ready():
	GlobalGameEvents.current_player_hp = current_hp
	GlobalGameEvents.hp_changed.emit(current_hp)
	barrier_sprite.pause()

func _physics_process(_delta):
	# 1. 입력 벡터 가져오기 (상하좌우 키 설정을 한 번에 처리)
	# "left", "right", "up", "down"은 Input Map에서 설정한 이름
	var direction = Input.get_vector("left", "right", "up", "down")
	_update_player_sprite(direction)
	# dash
	player_dash.update_last_direction(direction)
	if Input.is_action_just_pressed("dash"):
		player_dash.try_dash(direction)
	
	# dash: on이면 velocity ^
	if player_dash.is_dashing:
		velocity = player_dash.get_dash_velocity()
	else: 
		# 2. 이동 방향이 있을 때만 속도 설정
		if direction != Vector2.ZERO:
			velocity = direction * speed
		else:
			#인풋없으면 정지 
			velocity = Vector2.ZERO
	
	#이동 및 충돌 처리
	move_and_slide()
	
	#플레이어 화면안에 가두기
	var screen_size = get_viewport_rect().size
	# 화면 크기 - 플레이어 절반 크기로 경계선 제한
	position.x = clamp(position.x, player_half, screen_size.x - player_half)
	position.y = clamp(position.y, player_half, screen_size.y - player_half)

func _update_player_sprite(direction: Vector2) -> void:
	if direction.x < -0.1:
		player_sprite.play("left")
	elif direction.x > 0.1:
		player_sprite.play("right")
	else:
		player_sprite.play("default")


func _process(_delta):
	# 'fire' 키를 누르기 시작할 때
	if Input.is_action_just_pressed("fire"):
		start_shooting()
	
	# 'fire' 키를 뗐을 때
	if Input.is_action_just_released("fire"):
		stop_shooting()
		player_bullet_manager.stop_laser()

func start_shooting():
	shoot_timer.start()

func stop_shooting():
	shoot_timer.stop()

# 타이머의 'timeout' 시그널을 연결
func _on_shoot_timer_timeout():
	shoot()
	
func shoot():
	var dir:Vector2=Vector2.UP
	player_bullet_manager.fire_bullet(global_position, dir)
	


func take_damage(amount: int):
	# 무적 체크박스가 켜져 있다면, 아래 코드를 무시하고 함수를 나감.
	if is_invincible:
		return 

	current_hp -= amount
	current_hp = max(0, current_hp)
	
	GlobalGameEvents.current_player_hp = current_hp
	
	print("현재 피: ", current_hp)
	GlobalGameEvents.hp_changed.emit(current_hp)
	#피격 스프라이트 및 효과음 출력
	explosion_sprite.show()
	explosion_sprite.play("default")
	damaged_sfx.play()
	
	if current_hp <= 0:
		die()
		return
	#죽지 않았다면 무적시간 부여(await문 참조)
	is_invincible=true
	print("플레이어 무적 부여")
	var tween = create_tween()
	tween.tween_property(player_sprite, "modulate:a", 0.5, 0.3) # 반투명하게
	tween.tween_property(player_sprite, "modulate:a", 1.0, 0.3) # 다시 보이게
	await get_tree().create_timer(1.0).timeout
	explosion_sprite.hide()
	print("무적 종료")
	is_invincible=false
	
func die():
	print("사망")
	GlobalGameEvents.game_over.emit()
	
	# 플레이어 조작 중지 및 숨기기
	set_physics_process(false)
	set_process(false)
	hide()
