extends CharacterBody2D

@export var max_hp: int = 1000
@export var hit_flash_time: float = 0.08
@export var clear_score: int = 3000 #클리어시 추가되는 점수
@export var fire_time:float = 0.1

@onready var boss_bullet_manager = %BossBulletManager
@onready var fire_timer: Timer = $FireTimer#총알 발사간격
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var pattern_timer: Timer = $PatternTimer
#5.26 패턴 작동방식을 AUTOSTART되는 타이머가 TIMEOUT될때마다 호출하는식으로 바꿈

var current_hp: int = 100
var current_phase=1
var phase_point1:int=0
var phase_point2:int=0

var pattern_num:int = 1
var pos: Vector2 = Vector2.ZERO

var variation: float = 0.0#공격패턴 변화 인수

var is_dead: bool = false


func _on_ready() -> void:
	current_hp = max_hp
	fire_timer.wait_time=fire_time
	#pattern_timer가 다 탔을때마다 패턴 발사하도록 설정
	pattern_timer.timeout.connect(boss_attack)
	
	GlobalGameEvents.boss_hp_changed.connect(phase_manager)
	GlobalGameEvents.boss_hp_changed.emit(current_hp, max_hp)
	
	phase_point1 = int(max_hp*0.65)
	phase_point2 = int(max_hp*0.3)
	boss_attack()
	
func _process(_float)->void:
	pos = global_position
	
func phase_manager(current_hp:int,_max_hp:int)->void:
	#현재 체력에 따라 페이즈를 바꿈 
	#print(phase_point1," ",phase_point2," ",current_hp)
	if (phase_point2 <= current_hp && current_hp <= phase_point1):
		current_phase=2
		print("PHASE2")
	elif (current_hp < phase_point2):
		current_phase=3
		print("PHASE3")
	
func boss_attack():
	#페이즈 따라 패턴 바꿔가며 공격
	#5.26: while문 안에 타이머 넣으면 프레임마다 실행되는 반복문으로 인해 게임 터짐;ㅈㅅㅈㅅ!!
	pattern_random()#페이즈 넘버를 랜덤으로 뽑는 함수
	match current_phase:
		1:
			phase1_pattern_fire()
		2:
			phase2_pattern_fire()
		3:
			phase3_pattern_fire()
	variation=0
		
		
func pattern_random():#같은 숫자가 안나올때까지 주사위를 굴리는 함수입니다
	var temp:int = pattern_num
	pattern_num=randi_range(1,3)
	while (pattern_num==temp):
		pattern_num=randi_range(1,3)

func phase1_pattern_fire():
	match pattern_num:
		1:
			p1_pattern1()
		2:
			#print(pattern_num," patternchanged")
			p1_pattern2()
		3:
			p1_pattern3()
	
func phase2_pattern_fire():
	#pattern_num=randi_range(1,3)
	pattern_num=1
	match pattern_num:
		1:
			p1_pattern1()
		_:
			#print(pattern_num," patternchanged")
			p1_pattern1()
			
func phase3_pattern_fire():
	#pattern_num=randi_range(1,3)
	pattern_num=1
	match pattern_num:
		1:
			p1_pattern1()
		_:
			#print(pattern_num," patternchanged")
			p1_pattern1()

func p1_pattern1() -> void:#페이즈1 패턴1, 흩뿌리기
	if is_dead:
		return
	variation=0.0
	for i in range(25):
		fire_timer.start()
		await fire_timer.timeout
		boss_bullet_manager.fire_p1_pattern1_radial(pos, variation)
		variation += 1.5

func p1_pattern2()->void:#페이즈1패턴2 일시유도탄
	if is_dead:
		return
	for i in range(3):
		print("pattern shootoff!")
		boss_bullet_manager.fire_p1_pattern2_follow(pos)
		await get_tree().create_timer(1.5).timeout

func p1_pattern3()->void:#페이즈3패턴3 낙뢰
	if is_dead:
		return
	for i in range(4):
		boss_bullet_manager.fire_p1_pattern3_shunrai()
		await get_tree().create_timer(1.5).timeout


func take_damage(amount: int) -> void:
	if is_dead:
		return

	if amount <= 0:
		return

	current_hp -= amount
	current_hp = max(current_hp, 0)

	print("보스 현재 체력: ", current_hp, "/", max_hp)

	GlobalGameEvents.boss_hp_changed.emit(current_hp, max_hp)

	_flash_hit()

	if current_hp <= 0:
		die()


func _flash_hit() -> void:
	if not sprite:
		return

	sprite.modulate = Color(1.0, 0.35, 0.35)

	await get_tree().create_timer(hit_flash_time).timeout

	if not is_dead and sprite:
		sprite.modulate = Color(1.0, 1.0, 1.0)


func die() -> void:
	if is_dead:
		return

	is_dead = true

	GlobalGameEvents.request_score_change.emit(clear_score)
	GlobalGameEvents.game_clear.emit()

	queue_free()
