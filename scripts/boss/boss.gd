extends CharacterBody2D

@export var max_hp: int = 1000
@export var hit_flash_time: float = 0.08
@export var clear_score: int = 3000 #클리어시 추가되는 점수
@export var pattern_time:float = 4.0#한 패턴의 지속시간
@export var fire_time:float = 0.1

@onready var boss_bullet_manager = %BossBulletManager
@onready var fire_timer: Timer = $Timer#총알 발사간격
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_hp: int = 100
var current_phase=1
var phase_point1:int=0
var phase_point2:int=0

var pattern_num:int = 0
var pattern_flag:bool=false#4초지나면 패턴 중지
var pos: Vector2 = Vector2.ZERO

var variation: float = 0.0#공격패턴 변화 인수
var variFlag:bool=false#인수값 조절용 플래그

var is_dead: bool = false


func _on_ready() -> void:
	current_hp = max_hp
	fire_timer.wait_time=fire_time
	GlobalGameEvents.boss_hp_changed.connect(phase_manager)
	GlobalGameEvents.boss_hp_changed.emit(current_hp, max_hp)
	
	phase_point1 = int(max_hp*0.65)
	phase_point2 = int(max_hp*0.3)
	boss_attack()
	
func _process(float)->void:
	pos = global_position
	
func phase_manager(current_hp:int,max_hp:int)->void:
	#print(phase_point1," ",phase_point2," ",current_hp)
	if (phase_point2 <= current_hp && current_hp <= phase_point1):
		current_phase=2
		print("PHASE2")
	elif (current_hp < phase_point2):
		current_phase=3
		print("PHASE3")
	
func boss_attack():
	while(!is_dead):#죽지 않았다면 반복
		#패턴을 고른다. 타이머를 켠다.타이머동안 패턴을 쏜다.
		#타이머가 끝나면 패턴을 다시고른다.
		#pick()
		pattern_flag=true
		match current_phase:
			1:
				phase1_pattern_fire()
			2:
				phase2_pattern_fire()
			3:
				phase3_pattern_fire()
		await get_tree().create_timer(pattern_time).timeout
		pattern_flag=false;
		

func phase1_pattern_fire():
	pattern_num=randi_range(1,3)
	while(pattern_flag):
		fire_timer.start()
		await fire_timer.timeout
		match pattern_num:
			1:
				p1_pattern1()
			_:
				#print(pattern_num," patternchanged")
				p1_pattern1()
func phase2_pattern_fire():
	pattern_num=randi_range(1,3)
	while(pattern_flag):
		fire_timer.start()
		await fire_timer.timeout
		match pattern_num:
			1:
				p1_pattern1()
			_:
				p1_pattern1()
func phase3_pattern_fire():
	pattern_num=randi_range(1,3)
	while(pattern_flag):
		fire_timer.start()
		await fire_timer.timeout
		match pattern_num:
			1:
				p1_pattern1()
			_:
				p1_pattern1()

func p1_pattern1() -> void:
	if is_dead:
		return
	boss_bullet_manager.fire_pattern1_radial(pos, variation)
	if variFlag:
		variation +=1.5
	else:
		variation -=1.5
	if variation < -3.0 :
		variFlag=true
	if variation > 3.0:
		variFlag=false


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
